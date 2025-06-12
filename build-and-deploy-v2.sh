#!/bin/bash

# Build and deploy eaglegpt with better monitoring
set -e

echo "🚀 EagleGPT Build & Deploy (with monitoring)"
echo "==========================================="
echo ""

SERVER_CONTEXT="hel1"
IMAGE_NAME="eaglegpt"
IMAGE_FILE="/tmp/eaglegpt-image.tar"
LOG_FILE="/tmp/eaglegpt-build.log"

# Clean up old files
rm -f ${IMAGE_FILE} ${LOG_FILE}

# Function to monitor disk space
monitor_disk() {
    while true; do
        DISK_USAGE=$(docker --context ${SERVER_CONTEXT} run --rm alpine df -h / 2>/dev/null | tail -1 | awk '{print $5}' | sed 's/%//')
        echo "[$(date +%H:%M:%S)] Server disk usage: ${DISK_USAGE}%" >> ${LOG_FILE}
        if [ "$DISK_USAGE" -gt 90 ]; then
            echo "⚠️  WARNING: Server disk usage above 90%!" | tee -a ${LOG_FILE}
        fi
        sleep 30
    done
}

# Start disk monitoring in background
monitor_disk &
MONITOR_PID=$!

# Function to cleanup on exit
cleanup() {
    echo "Cleaning up..."
    kill $MONITOR_PID 2>/dev/null || true
    rm -f ${IMAGE_FILE}
}
trap cleanup EXIT

# Step 1: Build the image locally
echo "📦 Step 1: Building Docker image locally..."
echo "This will take 10-15 minutes on first build..."
echo "Build output will be saved to: ${LOG_FILE}"
echo ""

# Build with progress and save output
docker build -t ${IMAGE_NAME}:latest . \
    --progress=plain \
    --no-cache \
    2>&1 | tee ${LOG_FILE} &

BUILD_PID=$!

# Monitor build progress
while kill -0 $BUILD_PID 2>/dev/null; do
    echo -n "."
    sleep 5
done
wait $BUILD_PID
BUILD_EXIT_CODE=$?

echo ""

if [ $BUILD_EXIT_CODE -ne 0 ]; then
    echo "❌ Build failed! Check ${LOG_FILE} for details"
    tail -50 ${LOG_FILE}
    exit 1
fi

echo "✅ Build completed successfully!"

# Step 2: Save the image
echo ""
echo "💾 Step 2: Saving image to tar file..."
docker save ${IMAGE_NAME}:latest -o ${IMAGE_FILE}
echo "✅ Image saved to ${IMAGE_FILE} ($(du -h ${IMAGE_FILE} | cut -f1))"

# Step 3: Transfer to server
echo ""
echo "📤 Step 3: Transferring image to server..."
echo "Using docker load via pipe..."

cat ${IMAGE_FILE} | docker --context ${SERVER_CONTEXT} load

echo "✅ Image loaded on server!"

# Step 4: Stop existing container
echo ""
echo "🛑 Step 4: Stopping existing eaglegpt container (if any)..."
docker --context ${SERVER_CONTEXT} stop eaglegpt 2>/dev/null || true
docker --context ${SERVER_CONTEXT} rm eaglegpt 2>/dev/null || true

# Step 5: Run the container
echo ""
echo "🚀 Step 5: Starting eaglegpt container..."
docker --context ${SERVER_CONTEXT} run -d \
    --name eaglegpt \
    --restart unless-stopped \
    -p 3000:8080 \
    -v eaglegpt-data:/app/backend/data \
    -e WEBUI_NAME="eagleGPT" \
    -e WEBUI_URL="http://95.217.152.30:3000" \
    -e WEBUI_SECRET_KEY="$(openssl rand -hex 32)" \
    -e ENABLE_SIGNUP="true" \
    ${IMAGE_NAME}:latest

# Step 6: Verify deployment
echo ""
echo "🔍 Step 6: Verifying deployment..."
sleep 5

if docker --context ${SERVER_CONTEXT} ps | grep -q eaglegpt; then
    echo "✅ eaglegpt is running!"
    echo ""
    echo "📋 Container status:"
    docker --context ${SERVER_CONTEXT} ps | grep eaglegpt
    echo ""
    echo "📝 Recent logs:"
    docker --context ${SERVER_CONTEXT} logs eaglegpt --tail 20
else
    echo "❌ eaglegpt failed to start!"
    docker --context ${SERVER_CONTEXT} logs eaglegpt
    exit 1
fi

# Final server disk check
echo ""
echo "💾 Final server disk usage:"
docker --context ${SERVER_CONTEXT} run --rm alpine df -h /

echo ""
echo "🎉 Deployment complete!"
echo "🌐 Access eagleGPT at: http://95.217.152.30:3000"
echo ""
echo "📝 Useful commands:"
echo "   Check logs: docker --context ${SERVER_CONTEXT} logs eaglegpt"
echo "   Restart: docker --context ${SERVER_CONTEXT} restart eaglegpt"
echo "   Stop: docker --context ${SERVER_CONTEXT} stop eaglegpt"