#!/bin/bash

# Direct deployment of eaglegpt on server
# This script deploys directly on the server without local building

set -e

echo "🚀 EagleGPT Direct Server Deployment"
echo "===================================="
echo ""

SERVER_CONTEXT="hel1"
CONTAINER_NAME="eaglegpt"

# Step 1: Archive the customizations
echo "📦 Step 1: Creating customization archive..."
tar -czf eaglegpt-custom.tar.gz \
    src/routes/welcome \
    src/lib/components/PreviewChat.svelte \
    src/routes/+layout.svelte \
    src/lib/components/layout/Sidebar.svelte \
    src/lib/components/chat/Chat.svelte \
    src/routes/auth/+page.svelte \
    static/flag-background-2.png \
    2>/dev/null || true

echo "✅ Archive created"

# Step 2: Get server details
SERVER_HOST=$(docker context inspect ${SERVER_CONTEXT} | grep -o '"Host":"[^"]*"' | cut -d'"' -f4 | cut -d':' -f1)
echo ""
echo "📝 Manual deployment steps:"
echo ""
echo "1. Copy the customization archive to your server:"
echo "   scp eaglegpt-custom.tar.gz root@${SERVER_HOST}:/tmp/"
echo ""
echo "2. SSH into your server:"
echo "   ssh root@${SERVER_HOST}"
echo ""
echo "3. On the server, run these commands:"
echo ""
cat << 'EOF'
# Stop existing container
docker stop eaglegpt 2>/dev/null || true
docker rm eaglegpt 2>/dev/null || true

# Pull the latest OpenWebUI image from GitHub
docker pull ghcr.io/open-webui/open-webui:main

# Create a volume for customizations
docker volume create eaglegpt-custom

# Extract customizations to a temporary container
docker run --rm -v eaglegpt-custom:/custom alpine sh -c "
  cd /custom && 
  tar -xzf /tmp/eaglegpt-custom.tar.gz
"

# Run eaglegpt with customizations mounted
docker run -d \
  --name eaglegpt \
  --restart unless-stopped \
  -p 3000:8080 \
  -v eaglegpt-data:/app/backend/data \
  -v eaglegpt-custom:/custom:ro \
  -e WEBUI_NAME="eagleGPT" \
  -e WEBUI_AUTH=true \
  ghcr.io/open-webui/open-webui:main \
  bash -c "
    # Copy customizations over the base files
    cp -rf /custom/src/* /app/src/ 2>/dev/null || true
    cp -rf /custom/static/* /app/static/ 2>/dev/null || true
    # Start the application
    ./start.sh
  "

# Check status
docker ps | grep eaglegpt
docker logs eaglegpt --tail 20
EOF

echo ""
echo "4. Your eaglegpt instance will be available at: http://${SERVER_HOST}:3000"
echo ""
echo "Note: The customizations will be applied when the container starts."