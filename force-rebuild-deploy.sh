#!/bin/bash

# Force rebuild without cache
set -e

echo "🚀 EagleGPT Force Rebuild & Deploy"
echo "================================="
echo ""

SERVER_CONTEXT="hel1"
IMAGE_NAME="eaglegpt"
IMAGE_FILE="/tmp/eaglegpt-image.tar"

# Step 1: Remove local image to force fresh build
echo "🧹 Step 1: Removing local image..."
docker rmi ${IMAGE_NAME}:latest || true

# Step 2: Build with no cache
echo ""
echo "📦 Step 2: Building Docker image (no cache)..."
docker build -t ${IMAGE_NAME}:latest . --no-cache --progress=plain

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build completed successfully!"

# Step 3: Save the image
echo ""
echo "💾 Step 3: Saving image..."
docker save ${IMAGE_NAME}:latest -o ${IMAGE_FILE}
IMAGE_SIZE=$(du -h ${IMAGE_FILE} | cut -f1)
echo "✅ Image saved: ${IMAGE_SIZE}"

# Step 4: Transfer to server
echo ""
echo "📤 Step 4: Transferring to server..."
cat ${IMAGE_FILE} | docker --context ${SERVER_CONTEXT} load
echo "✅ Image loaded on server!"

# Step 5: Stop and remove old container
echo ""
echo "🛑 Step 5: Stopping old container..."
docker --context ${SERVER_CONTEXT} stop eaglegpt 2>/dev/null || true
docker --context ${SERVER_CONTEXT} rm eaglegpt 2>/dev/null || true

# Step 6: Start new container
echo ""
echo "🚀 Step 6: Starting new container..."
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

# Step 7: Verify
echo ""
echo "🔍 Step 7: Verifying..."
sleep 5

if docker --context ${SERVER_CONTEXT} ps | grep -q eaglegpt; then
    echo "✅ eaglegpt is running!"
    echo ""
    docker --context ${SERVER_CONTEXT} ps | grep eaglegpt
    echo ""
    echo "📝 Logs:"
    docker --context ${SERVER_CONTEXT} logs eaglegpt --tail 20
else
    echo "❌ Failed to start!"
    docker --context ${SERVER_CONTEXT} logs eaglegpt
    exit 1
fi

# Cleanup
rm -f ${IMAGE_FILE}

echo ""
echo "🎉 Force rebuild complete!"
echo "🌐 Access at: http://95.217.152.30:3000"