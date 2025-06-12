#!/bin/bash

# Deploy eaglegpt using pre-built image with customizations
set -e

echo "🚀 EagleGPT Quick Deploy (Pre-built Image)"
echo "=========================================="
echo ""

SERVER_CONTEXT="hel1"
CONTAINER_NAME="eaglegpt"

# Step 1: Create customization archive
echo "📦 Step 1: Creating customization archive..."
tar -czf /tmp/eaglegpt-custom.tar.gz \
    src/routes/welcome \
    src/lib/components/PreviewChat.svelte \
    src/routes/+layout.svelte \
    src/lib/components/layout/Sidebar.svelte \
    src/lib/components/chat/Chat.svelte \
    src/routes/auth/+page.svelte \
    static/flag-background-2.png \
    2>/dev/null || true

echo "✅ Customizations archived"

# Step 2: Stop existing container
echo ""
echo "🛑 Step 2: Stopping existing container (if any)..."
docker --context ${SERVER_CONTEXT} stop ${CONTAINER_NAME} 2>/dev/null || true
docker --context ${SERVER_CONTEXT} rm ${CONTAINER_NAME} 2>/dev/null || true

# Step 3: Pull pre-built image
echo ""
echo "📥 Step 3: Pulling pre-built OpenWebUI image..."
docker --context ${SERVER_CONTEXT} pull openwebui/open-webui:main

# Step 4: Create volume and copy customizations
echo ""
echo "📂 Step 4: Setting up customization volume..."
docker --context ${SERVER_CONTEXT} volume create eaglegpt-custom

# Copy customizations to server
cat /tmp/eaglegpt-custom.tar.gz | docker --context ${SERVER_CONTEXT} run -i --rm \
    -v eaglegpt-custom:/custom \
    alpine sh -c "cd /custom && tar -xzf - && ls -la"

# Step 5: Run container with customizations
echo ""
echo "🚀 Step 5: Starting eaglegpt with customizations..."
docker --context ${SERVER_CONTEXT} run -d \
    --name ${CONTAINER_NAME} \
    --restart unless-stopped \
    -p 3000:8080 \
    -v eaglegpt-data:/app/backend/data \
    -v eaglegpt-custom:/custom:ro \
    -e WEBUI_NAME="eagleGPT" \
    -e WEBUI_URL="http://95.217.152.30:3000" \
    -e WEBUI_SECRET_KEY="$(openssl rand -hex 32)" \
    -e ENABLE_SIGNUP="true" \
    openwebui/open-webui:main \
    sh -c "
        # Apply customizations
        if [ -d /custom/src ]; then
            echo 'Applying customizations...'
            cp -rf /custom/src/* /app/src/ 2>/dev/null || true
            cp -rf /custom/static/* /app/static/ 2>/dev/null || true
            echo 'Customizations applied!'
        fi
        # Start the application
        exec ./start.sh
    "

# Step 6: Verify deployment
echo ""
echo "🔍 Step 6: Verifying deployment..."
sleep 10

if docker --context ${SERVER_CONTEXT} ps | grep -q ${CONTAINER_NAME}; then
    echo "✅ eaglegpt is running!"
    echo ""
    echo "📋 Container status:"
    docker --context ${SERVER_CONTEXT} ps | grep ${CONTAINER_NAME}
    echo ""
    echo "📝 Recent logs:"
    docker --context ${SERVER_CONTEXT} logs ${CONTAINER_NAME} --tail 30
else
    echo "❌ eaglegpt failed to start!"
    docker --context ${SERVER_CONTEXT} logs ${CONTAINER_NAME}
    exit 1
fi

# Check disk usage
echo ""
echo "💾 Server disk usage:"
docker --context ${SERVER_CONTEXT} run --rm alpine df -h /

echo ""
echo "🎉 Deployment complete!"
echo "🌐 Access eagleGPT at: http://95.217.152.30:3000"
echo ""
echo "📝 Useful commands:"
echo "   Check logs: docker --context ${SERVER_CONTEXT} logs ${CONTAINER_NAME} -f"
echo "   Restart: docker --context ${SERVER_CONTEXT} restart ${CONTAINER_NAME}"
echo "   Stop: docker --context ${SERVER_CONTEXT} stop ${CONTAINER_NAME}"

# Cleanup
rm -f /tmp/eaglegpt-custom.tar.gz