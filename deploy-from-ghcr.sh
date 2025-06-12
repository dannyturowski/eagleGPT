#!/bin/bash

# GitHub Container Registry deployment script
echo "🚀 Deploying eagleGPT from GHCR"
echo "================================"

# Configuration
GHCR_IMAGE="ghcr.io/dannyturowski/eaglegpt:latest"
CONTAINER_NAME="eaglegpt"
SERVER_CONTEXT="hel1"

# Function to deploy
deploy() {
    echo "📦 Pulling latest image from GHCR..."
    docker --context $SERVER_CONTEXT pull $GHCR_IMAGE
    
    echo "🛑 Stopping old container..."
    docker --context $SERVER_CONTEXT stop $CONTAINER_NAME 2>/dev/null || true
    docker --context $SERVER_CONTEXT rm $CONTAINER_NAME 2>/dev/null || true
    
    echo "🚀 Starting new container..."
    docker --context $SERVER_CONTEXT run -d \
        --name $CONTAINER_NAME \
        --restart unless-stopped \
        -p 3000:8080 \
        -v /opt/openwebui/data:/app/backend/data \
        -v /opt/openwebui/backup:/app/backup \
        -e WEBUI_NAME="eagleGPT" \
        -e WEBUI_URL="http://95.217.152.30:3000" \
        -e WEBUI_SECRET_KEY="$(openssl rand -hex 32)" \
        -e ENABLE_SIGNUP="true" \
        $GHCR_IMAGE
    
    echo "⏳ Waiting for container to start..."
    sleep 15
    
    echo "🔍 Verifying deployment..."
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://95.217.152.30:3000/)
    if [ "$HTTP_CODE" = "200" ]; then
        echo "✅ Deployment successful! HTTP: $HTTP_CODE"
    else
        echo "❌ Deployment may have failed. HTTP: $HTTP_CODE"
    fi
    
    echo "📝 Container logs:"
    docker --context $SERVER_CONTEXT logs $CONTAINER_NAME --tail 20
}

# Check if we need to authenticate to GHCR (for private repos)
if [ ! -z "$GITHUB_TOKEN" ]; then
    echo "🔐 Logging in to GHCR..."
    echo $GITHUB_TOKEN | docker --context $SERVER_CONTEXT login ghcr.io -u $GITHUB_USERNAME --password-stdin
fi

# Run deployment
deploy

echo ""
echo "✅ Deployment complete!"
echo "📋 Next steps:"
echo "1. Update GHCR_IMAGE in this script with your GitHub username"
echo "2. Set up GitHub Actions secrets if needed"
echo "3. Push to main branch to trigger automatic builds"