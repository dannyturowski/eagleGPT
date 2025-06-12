#!/bin/bash

# Automated EagleGPT Build and Deploy Script
# Uses docker save/load to transfer images without a registry

set -e

echo "🚀 EagleGPT Build & Deploy (Registry-Free)"
echo "=========================================="
echo ""

# Configuration
IMAGE_NAME="eaglegpt"
CONTAINER_NAME="eaglegpt"
IMAGE_FILE="eaglegpt-image.tar"
SERVER_CONTEXT="hel1"

# Step 1: Build locally
echo "📦 Step 1: Building Docker image locally..."
echo "This will take 10-15 minutes on first build..."

# Check if image already exists
if docker images | grep -q "^${IMAGE_NAME}.*latest"; then
    echo "⚠️  Image ${IMAGE_NAME}:latest already exists"
    read -p "Rebuild? (y/N): " rebuild
    if [[ $rebuild =~ ^[Yy]$ ]]; then
        docker build -t ${IMAGE_NAME}:latest . || {
            echo "❌ Build failed. Common issues:"
            echo "  - Out of memory: Close other applications"
            echo "  - Disk space: Check with 'df -h'"
            echo "  - Network: Ensure stable internet connection"
            exit 1
        }
    fi
else
    docker build -t ${IMAGE_NAME}:latest . || {
        echo "❌ Build failed. See error above."
        exit 1
    }
fi

echo "✅ Build complete!"

# Step 2: Save image to file
echo ""
echo "💾 Step 2: Saving Docker image to file..."
docker save ${IMAGE_NAME}:latest -o ${IMAGE_FILE}
echo "✅ Image saved to ${IMAGE_FILE} ($(du -h ${IMAGE_FILE} | cut -f1))"

# Step 3: Load image on server
echo ""
echo "📤 Step 3: Loading image on server..."
echo "Transferring image file to server context..."

# Use docker context to load the image
cat ${IMAGE_FILE} | docker --context ${SERVER_CONTEXT} load

echo "✅ Image loaded on server!"

# Step 4: Deploy container
echo ""
echo "🌐 Step 4: Deploying container..."

# Stop existing container
echo "Stopping existing container (if any)..."
docker --context ${SERVER_CONTEXT} stop ${CONTAINER_NAME} 2>/dev/null || true
docker --context ${SERVER_CONTEXT} rm ${CONTAINER_NAME} 2>/dev/null || true

# Run new container
echo "Starting new container..."
docker --context ${SERVER_CONTEXT} run -d \
    --name ${CONTAINER_NAME} \
    --restart unless-stopped \
    -p 3000:8080 \
    -v eaglegpt_data:/app/backend/data \
    -e WEBUI_AUTH=true \
    ${IMAGE_NAME}:latest

# Check status
echo ""
echo "🔍 Checking deployment status..."
if docker --context ${SERVER_CONTEXT} ps | grep -q ${CONTAINER_NAME}; then
    echo "✅ Container is running!"
    echo ""
    docker --context ${SERVER_CONTEXT} ps --filter name=${CONTAINER_NAME} --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo "📝 Recent logs:"
    docker --context ${SERVER_CONTEXT} logs --tail 10 ${CONTAINER_NAME}
    echo ""
    SERVER_IP=$(docker context inspect ${SERVER_CONTEXT} | grep -o '"Host":"[^"]*"' | cut -d'"' -f4 | cut -d':' -f1)
    echo "🎉 Deployment complete!"
    echo "Access your application at: http://${SERVER_IP}:3000"
else
    echo "❌ Container failed to start. Checking logs..."
    docker --context ${SERVER_CONTEXT} logs ${CONTAINER_NAME}
    exit 1
fi

# Cleanup
echo ""
read -p "Remove local image file? (y/N): " cleanup
if [[ $cleanup =~ ^[Yy]$ ]]; then
    rm -f ${IMAGE_FILE}
    echo "✅ Cleaned up ${IMAGE_FILE}"
fi