#!/bin/bash

# EagleGPT Deployment Script
# This script builds, tags, pushes, and deploys the eaglegpt image

set -e  # Exit on any error

# Configuration
REGISTRY_IP="95.217.152.30"
REGISTRY_PORT="5000"
IMAGE_NAME="eaglegpt"
CONTAINER_NAME="eaglegpt"

echo "🚀 EagleGPT Deployment Script"
echo "============================="
echo ""

# Step 1: Check if build is complete
echo "📦 Step 1: Checking Docker image..."
if docker images | grep -q "^${IMAGE_NAME}.*latest"; then
    echo "✅ Image ${IMAGE_NAME}:latest found"
else
    echo "⏳ Building image... (this may take 10-15 minutes)"
    docker build -t ${IMAGE_NAME}:latest .
    echo "✅ Build complete"
fi

# Step 2: Tag the image for the registry
echo ""
echo "🏷️  Step 2: Tagging image for registry..."
docker tag ${IMAGE_NAME}:latest ${REGISTRY_IP}:${REGISTRY_PORT}/${IMAGE_NAME}:latest
echo "✅ Image tagged as ${REGISTRY_IP}:${REGISTRY_PORT}/${IMAGE_NAME}:latest"

# Step 3: Push to registry
echo ""
echo "📤 Step 3: Pushing image to registry..."
echo "Note: If this fails with 'server gave HTTP response to HTTPS client', you need to configure Docker to accept insecure registries"
docker push ${REGISTRY_IP}:${REGISTRY_PORT}/${IMAGE_NAME}:latest
echo "✅ Image pushed successfully"

# Step 4: Deploy on server
echo ""
echo "🌐 Step 4: Deploying on server..."

# Stop existing container if running
echo "Stopping existing container (if any)..."
docker --context hel1 stop ${CONTAINER_NAME} 2>/dev/null || true
docker --context hel1 rm ${CONTAINER_NAME} 2>/dev/null || true

# Pull the new image on server
echo "Pulling image on server..."
docker --context hel1 pull localhost:5000/${IMAGE_NAME}:latest

# Run the new container
echo "Starting new container..."
docker --context hel1 run -d \
    --name ${CONTAINER_NAME} \
    --restart unless-stopped \
    -p 3000:8080 \
    -v eaglegpt_data:/app/backend/data \
    localhost:5000/${IMAGE_NAME}:latest

# Check if container is running
echo ""
echo "🔍 Checking deployment status..."
if docker --context hel1 ps | grep -q ${CONTAINER_NAME}; then
    echo "✅ Container is running!"
    echo ""
    echo "📊 Container details:"
    docker --context hel1 ps --filter name=${CONTAINER_NAME}
    echo ""
    echo "📝 Recent logs:"
    docker --context hel1 logs --tail 20 ${CONTAINER_NAME}
else
    echo "❌ Container failed to start. Checking logs..."
    docker --context hel1 logs ${CONTAINER_NAME}
fi

echo ""
echo "🎉 Deployment complete!"
echo "Access your application at: http://${REGISTRY_IP}:3000"