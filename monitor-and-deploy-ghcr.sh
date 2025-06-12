#!/bin/bash

echo "🔄 Monitoring Docker build and auto-deploying to GHCR"
echo "===================================================="
echo "Time: $(date)"
echo ""

BUILD_PID=$(pgrep -f "docker build.*ghcr.io/dannyturowski/eaglegpt")
IMAGE_NAME="ghcr.io/dannyturowski/eaglegpt:latest"
SERVER_CONTEXT="hel1"
CHECK_INTERVAL=30

if [ -z "$BUILD_PID" ]; then
    echo "❌ No build process found"
    exit 1
fi

echo "📦 Found build process: PID $BUILD_PID"
echo "🔍 Monitoring build progress..."
echo ""

# Monitor build
while kill -0 $BUILD_PID 2>/dev/null; do
    echo -n "[$(date +%H:%M:%S)] Build running... "
    
    # Check build log for progress
    if [ -f /tmp/docker-build-local.log ]; then
        LAST_STEP=$(grep "^#[0-9]" /tmp/docker-build-local.log | tail -1 | cut -d' ' -f1-4)
        echo "($LAST_STEP)"
    else
        echo ""
    fi
    
    sleep $CHECK_INTERVAL
done

echo ""
echo "✅ Build completed!"

# Check if image was created
if docker images | grep -q "dannyturowski/eaglegpt.*latest"; then
    echo "🎉 Image built successfully!"
    
    echo ""
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
        
        echo "🔍 Verifying deployment..."
        HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://95.217.152.30:3000/)
        if [ "$HTTP_CODE" = "200" ]; then
            echo "✅ Deployment successful! HTTP: $HTTP_CODE"
            echo ""
            echo "🔓 Testing anonymous access..."
            curl -s http://95.217.152.30:3000/ | head -200 | grep -q "publicRoutes" && \
                echo "✅ Anonymous access fix appears to be applied!" || \
                echo "⚠️  Anonymous access fix may not be visible in HTML"
        else
            echo "❌ Deployment may have failed. HTTP: $HTTP_CODE"
        fi
        
        echo ""
        echo "📝 Container logs:"
        docker --context $SERVER_CONTEXT logs eaglegpt --tail 20
        
        echo ""
        echo "✅ Deployment complete!"
        echo "📋 Test at: https://eagleGPT.us (use incognito mode)"
    else
        echo "❌ Push to GHCR failed"
        echo "You may need to login: docker login ghcr.io"
    fi
else
    echo "❌ Build failed - no image found"
    echo "Check /tmp/docker-build-local.log for errors"
fi