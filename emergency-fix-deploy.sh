#!/bin/bash

# Emergency deployment to fix anonymous access
set -e

echo "🚨 EMERGENCY FIX: Anonymous Access"
echo "=================================="
echo ""

SERVER_CONTEXT="hel1"
IMAGE_NAME="eaglegpt-fixed"
TIMESTAMP=$(date +%s)

# Add a cache-busting comment to force rebuild
echo "// Cache bust: $TIMESTAMP" >> /mnt/c/eaglegpt/src/routes/+layout.svelte

echo "📦 Building with cache bust..."
docker build -t ${IMAGE_NAME}:latest . --no-cache --build-arg BUILDKIT_INLINE_CACHE=0

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build completed!"

# Remove cache bust comment
sed -i '$ d' /mnt/c/eaglegpt/src/routes/+layout.svelte

echo ""
echo "📤 Deploying to server..."

# Save to file first
docker save ${IMAGE_NAME}:latest -o /tmp/eaglegpt-emergency.tar
echo "✅ Image saved ($(du -h /tmp/eaglegpt-emergency.tar | cut -f1))"

# Transfer to server
cat /tmp/eaglegpt-emergency.tar | docker --context ${SERVER_CONTEXT} load

# Stop old container
docker --context ${SERVER_CONTEXT} stop eaglegpt 2>/dev/null || true
docker --context ${SERVER_CONTEXT} rm eaglegpt 2>/dev/null || true

# Start new container
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

echo ""
echo "⏳ Waiting for container to start..."
sleep 20

echo ""
echo "🔍 Verification:"
echo "==============="

# Test anonymous access
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://95.217.152.30:3000/)
echo "Root page HTTP status: $HTTP_CODE"

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ Page is accessible!"
    
    # Check for auth redirect
    CONTENT=$(curl -s http://95.217.152.30:3000/ | head -100)
    if echo "$CONTENT" | grep -q "window.location.*auth"; then
        echo "❌ Still redirecting to auth!"
    else
        echo "✅ No auth redirect detected!"
    fi
else
    echo "❌ Page returned $HTTP_CODE"
fi

# Cleanup
rm -f /tmp/eaglegpt-emergency.tar

echo ""
echo "🎯 Next Steps:"
echo "1. Clear ALL browser data for eagleGPT.us"
echo "2. Use a completely different browser or device"
echo "3. The auth check is in the client-side JavaScript"
echo ""
echo "Container logs:"
docker --context ${SERVER_CONTEXT} logs eaglegpt --tail 20