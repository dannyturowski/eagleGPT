#!/bin/bash

echo "🚀 Deploying fixes for eagleGPT"
echo "=============================="
echo "Fixes included:"
echo "✓ Anonymous user layout rendering (dark theme)"
echo "✓ Admin settings page initialization"
echo ""

IMAGE_NAME="ghcr.io/dannyturowski/eaglegpt:latest"
SERVER_CONTEXT="hel1"

# Function to check if image exists locally
check_local_image() {
    if docker images | grep -q "dannyturowski/eaglegpt.*latest"; then
        return 0
    else
        return 1
    fi
}

# Function to deploy
deploy() {
    echo "📤 Pushing to GitHub Container Registry..."
    docker push $IMAGE_NAME
    
    if [ $? -eq 0 ]; then
        echo "✅ Push successful!"
        
        echo ""
        echo "🚀 Deploying to server..."
        
        # Pull on server
        echo "📥 Pulling image on server..."
        docker --context $SERVER_CONTEXT pull $IMAGE_NAME
        
        # Stop old container
        echo "🛑 Stopping old container..."
        docker --context $SERVER_CONTEXT stop eaglegpt 2>/dev/null || true
        docker --context $SERVER_CONTEXT rm eaglegpt 2>/dev/null || true
        
        # Start new container
        echo "🚀 Starting new container..."
        docker --context $SERVER_CONTEXT run -d \
            --name eaglegpt \
            --restart unless-stopped \
            -p 3000:8080 \
            -v /opt/openwebui/data:/app/backend/data \
            -v /opt/openwebui/backup:/app/backup \
            -e WEBUI_NAME="eagleGPT" \
            -e WEBUI_URL="http://95.217.152.30:3000" \
            -e WEBUI_SECRET_KEY="$(openssl rand -hex 32)" \
            -e ENABLE_SIGNUP="true" \
            $IMAGE_NAME
        
        echo "⏳ Waiting for container to start..."
        sleep 20
        
        echo ""
        echo "✅ Deployment complete!"
        echo ""
        echo "📋 Test the fixes:"
        echo "1. Anonymous access: https://eagleGPT.us (incognito mode)"
        echo "2. Admin settings: https://eagleGPT.us/admin/settings/general"
        echo ""
        echo "The following should now work:"
        echo "- Dark theme for anonymous users"
        echo "- Admin settings page loads correctly"
        echo "- ENABLE_SIGNUP toggle functions properly"
    else
        echo "❌ Push to GHCR failed"
    fi
}

# Check if build is still running
BUILD_PID=$(pgrep -f "docker build.*ghcr.io/dannyturowski")
if [ -n "$BUILD_PID" ]; then
    echo "⏳ Build still in progress (PID: $BUILD_PID)"
    echo "Waiting for build to complete..."
    
    while kill -0 $BUILD_PID 2>/dev/null; do
        sleep 10
        echo -n "."
    done
    echo ""
fi

# Check if image was built
if check_local_image; then
    echo "✅ Image found locally"
    deploy
else
    echo "❌ No image found. Build may have failed."
    echo "Check /tmp/docker-build-fixes.log for errors"
fi