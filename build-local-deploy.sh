#!/bin/bash

# Build locally and deploy to server
set -e

echo "🚀 EagleGPT Local Build & Deploy"
echo "================================"
echo ""

SERVER_CONTEXT="hel1"
IMAGE_NAME="eaglegpt"
IMAGE_FILE="/tmp/eaglegpt-image.tar"

# Step 1: Build the image locally
echo "📦 Step 1: Building Docker image locally..."
echo "Using existing cloned repository..."

# Build the image
docker build -t ${IMAGE_NAME}:latest . \
    --progress=plain

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build completed successfully!"

# Step 2: Save the image
echo ""
echo "💾 Step 2: Saving image to tar file..."
docker save ${IMAGE_NAME}:latest -o ${IMAGE_FILE}
IMAGE_SIZE=$(du -h ${IMAGE_FILE} | cut -f1)
echo "✅ Image saved: ${IMAGE_SIZE}"

# Step 3: Check server disk space
echo ""
echo "🔍 Step 3: Checking server disk space..."
DISK_USAGE=$(docker --context ${SERVER_CONTEXT} run --rm alpine df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
echo "Server disk usage: ${DISK_USAGE}%"

if [ "$DISK_USAGE" -gt 85 ]; then
    echo "⚠️  Warning: Server disk usage is high!"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Step 4: Transfer to server
echo ""
echo "📤 Step 4: Transferring image to server..."
echo "This may take a few minutes..."

cat ${IMAGE_FILE} | docker --context ${SERVER_CONTEXT} load

echo "✅ Image loaded on server!"

# Step 5: Stop existing container
echo ""
echo "🛑 Step 5: Stopping existing container (if any)..."
docker --context ${SERVER_CONTEXT} stop eaglegpt 2>/dev/null || true
docker --context ${SERVER_CONTEXT} rm eaglegpt 2>/dev/null || true

# Step 6: Run the container
echo ""
echo "🚀 Step 6: Starting eaglegpt container..."
docker --context ${SERVER_CONTEXT} run -d \
    --name eaglegpt \
    --restart unless-stopped \
    -p 3000:8080 \
    -v /opt/openwebui/data:/app/backend/data \
    -v /opt/openwebui/backup:/app/backup \
    -e WEBUI_NAME="eagleGPT" \
    -e WEBUI_URL="http://95.217.152.30:3000" \
    -e WEBUI_SECRET_KEY="$(openssl rand -hex 32)" \
    -e ENABLE_SIGNUP="true" \
    ${IMAGE_NAME}:latest

# Step 7: Verify deployment
echo ""
echo "🔍 Step 7: Verifying deployment..."
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

# Final check
echo ""
echo "💾 Final server disk usage:"
docker --context ${SERVER_CONTEXT} run --rm alpine df -h /

# Cleanup
rm -f ${IMAGE_FILE}

echo ""
echo "🎉 Deployment complete!"
echo "🌐 Access eagleGPT at: http://95.217.152.30:3000"
echo ""
echo "📝 Useful commands:"
echo "   Check logs: docker --context ${SERVER_CONTEXT} logs eaglegpt -f"
echo "   Restart: docker --context ${SERVER_CONTEXT} restart eaglegpt"
echo "   Stop: docker --context ${SERVER_CONTEXT} stop eaglegpt"