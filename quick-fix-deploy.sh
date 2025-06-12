#!/bin/bash

# Quick deployment script for anonymous access fix
set -e

echo "🚀 Quick Fix Deploy for Anonymous Access"
echo "========================================"
echo ""

SERVER_CONTEXT="hel1"
IMAGE_NAME="eaglegpt"
IMAGE_FILE="/tmp/eaglegpt-fix.tar"

# Check if a build is already running
if pgrep -f "docker build" > /dev/null; then
    echo "⏳ A build is already in progress. Waiting for it to complete..."
    echo "   You can monitor with: docker logs $(docker ps -q -f name=buildx_buildkit)"
    exit 1
fi

# Step 1: Build locally
echo "📦 Building Docker image..."
docker build -t ${IMAGE_NAME}:latest . --progress=plain

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build completed successfully!"

# Step 2: Save the image
echo ""
echo "💾 Saving image..."
docker save ${IMAGE_NAME}:latest -o ${IMAGE_FILE}
IMAGE_SIZE=$(du -h ${IMAGE_FILE} | cut -f1)
echo "✅ Image saved: ${IMAGE_SIZE}"

# Step 3: Transfer to server
echo ""
echo "📤 Transferring to server..."
cat ${IMAGE_FILE} | docker --context ${SERVER_CONTEXT} load
echo "✅ Image loaded on server!"

# Step 4: Stop and remove old container
echo ""
echo "🛑 Stopping old container..."
docker --context ${SERVER_CONTEXT} stop eaglegpt 2>/dev/null || true
docker --context ${SERVER_CONTEXT} rm eaglegpt 2>/dev/null || true

# Step 5: Start new container with proper configuration
echo ""
echo "🚀 Starting new container..."
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

# Step 6: Verify
echo ""
echo "🔍 Verifying deployment..."
sleep 5

if docker --context ${SERVER_CONTEXT} ps | grep -q eaglegpt; then
    echo "✅ eaglegpt is running!"
    echo ""
    docker --context ${SERVER_CONTEXT} ps | grep eaglegpt
    echo ""
    echo "📝 Testing anonymous access..."
    sleep 3
    
    # Test root page
    HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" http://95.217.152.30:3000/)
    if [ "$HTTP_STATUS" = "200" ]; then
        echo "✅ Root page (/) is accessible: HTTP $HTTP_STATUS"
    else
        echo "❌ Root page (/) returned: HTTP $HTTP_STATUS"
    fi
    
    # Test API config
    API_NAME=$(curl -s http://95.217.152.30:3000/api/config | jq -r '.name' 2>/dev/null || echo "Failed")
    if [ "$API_NAME" = "eagleGPT" ]; then
        echo "✅ API returns correct name: $API_NAME"
    else
        echo "❌ API name issue: $API_NAME"
    fi
    
    echo ""
    echo "📝 Container logs:"
    docker --context ${SERVER_CONTEXT} logs eaglegpt --tail 20
else
    echo "❌ Failed to start!"
    docker --context ${SERVER_CONTEXT} logs eaglegpt
    exit 1
fi

# Cleanup
rm -f ${IMAGE_FILE}

echo ""
echo "🎉 Deployment complete!"
echo ""
echo "📋 To verify the fix:"
echo "1. Open an incognito/private browser window"
echo "2. Navigate to https://eagleGPT.us"
echo "3. You should see the chat interface without login"
echo "4. Authentication will be required only when sending messages"
echo ""
echo "🔧 If issues persist:"
echo "- Clear ALL browser data for eagleGPT.us"
echo "- Try a different browser"
echo "- Check browser console for errors"