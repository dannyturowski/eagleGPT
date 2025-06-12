#!/bin/bash

# Auto-deployment monitor script
echo "🤖 Auto-Deploy Monitor Started"
echo "=============================="
echo "Time: $(date)"
echo ""

SERVER_CONTEXT="hel1"
IMAGE_NAME="eaglegpt"
CHECK_INTERVAL=30  # Check every 30 seconds
MAX_CHECKS=120     # Maximum 60 minutes (120 * 30s)

# Function to check if build is running
is_build_running() {
    pgrep -f "docker build" > /dev/null || pgrep -f "npm run build" > /dev/null
}

# Function to check if image exists and is recent
is_image_ready() {
    # Check if image exists
    if docker images | grep -q "^${IMAGE_NAME}.*latest"; then
        # Get image creation time
        IMAGE_TIME=$(docker inspect ${IMAGE_NAME}:latest 2>/dev/null | jq -r '.[0].Created' | cut -d'T' -f1-2 | tr -d 'T:-')
        CURRENT_TIME=$(date -u +%Y%m%d%H%M)
        
        # Check if image was created in the last 10 minutes
        TIME_DIFF=$((CURRENT_TIME - IMAGE_TIME))
        if [ $TIME_DIFF -lt 10 ] && [ $TIME_DIFF -ge 0 ]; then
            return 0
        fi
    fi
    return 1
}

# Function to deploy the image
deploy_image() {
    echo ""
    echo "📦 Starting deployment..."
    echo "========================"
    
    # Save the image
    echo "💾 Saving image..."
    docker save ${IMAGE_NAME}:latest -o /tmp/eaglegpt-auto.tar
    IMAGE_SIZE=$(du -h /tmp/eaglegpt-auto.tar | cut -f1)
    echo "✅ Image saved: ${IMAGE_SIZE}"
    
    # Transfer to server
    echo ""
    echo "📤 Transferring to server..."
    cat /tmp/eaglegpt-auto.tar | docker --context ${SERVER_CONTEXT} load
    echo "✅ Image loaded on server!"
    
    # Stop old container
    echo ""
    echo "🛑 Stopping old container..."
    docker --context ${SERVER_CONTEXT} stop eaglegpt 2>/dev/null || true
    docker --context ${SERVER_CONTEXT} rm eaglegpt 2>/dev/null || true
    
    # Start new container
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
        eaglegpt:latest
    
    # Wait for startup
    echo ""
    echo "⏳ Waiting for container to start..."
    sleep 20
    
    # Verify deployment
    echo ""
    echo "🔍 Verifying deployment..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://95.217.152.30:3000/)
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ Deployment successful! HTTP: $HTTP_CODE"
        
        # Test anonymous access
        echo ""
        echo "🔓 Testing anonymous access..."
        CONTENT=$(curl -s http://95.217.152.30:3000/ | head -500)
        if echo "$CONTENT" | grep -q 'src="/_app/'; then
            echo "✅ App JavaScript is loading"
        else
            echo "⚠️  App JavaScript not found"
        fi
        
        # Check container logs
        echo ""
        echo "📝 Container logs:"
        docker --context ${SERVER_CONTEXT} logs eaglegpt --tail 10
    else
        echo "❌ Deployment may have failed. HTTP: $HTTP_CODE"
    fi
    
    # Cleanup
    rm -f /tmp/eaglegpt-auto.tar
    
    echo ""
    echo "🎉 Auto-deployment complete!"
    echo "Time: $(date)"
    echo ""
    echo "📋 Next steps:"
    echo "1. Clear browser cache for eagleGPT.us"
    echo "2. Visit https://eagleGPT.us in incognito mode"
    echo "3. You should see the chat interface without login"
}

# Main monitoring loop
CHECKS=0
while [ $CHECKS -lt $MAX_CHECKS ]; do
    CHECKS=$((CHECKS + 1))
    
    if is_build_running; then
        echo "[$(date +%H:%M:%S)] Build is running... (check $CHECKS/$MAX_CHECKS)"
    else
        echo "[$(date +%H:%M:%S)] No build detected, checking for new image..."
        
        if is_image_ready; then
            echo "✅ New image detected! Starting deployment..."
            deploy_image
            exit 0
        else
            echo "[$(date +%H:%M:%S)] No new image yet... (check $CHECKS/$MAX_CHECKS)"
        fi
    fi
    
    sleep $CHECK_INTERVAL
done

echo ""
echo "⏰ Timeout reached after $((MAX_CHECKS * CHECK_INTERVAL / 60)) minutes"
echo "Run this script again to continue monitoring"