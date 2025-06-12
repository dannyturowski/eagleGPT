#!/bin/bash

echo "🚀 Quick deployment with anonymous access fix"
echo "============================================"

# Since the full build is taking too long, let's try a different approach
# We'll pull the official image and patch it

SERVER_CONTEXT="hel1"

echo "📦 Pulling official Open WebUI image..."
docker pull ghcr.io/open-webui/open-webui:main

echo "🔧 Creating patched Dockerfile..."
cat > Dockerfile.patch << 'EOF'
FROM ghcr.io/open-webui/open-webui:main

# Copy our fixed layout files
COPY src/routes/(app)/+layout.svelte /app/src/routes/(app)/+layout.svelte
COPY src/routes/+layout.svelte /app/src/routes/+layout.svelte

# Rebuild the frontend with our changes
WORKDIR /app
RUN npm run build

# Set our custom environment
ENV WEBUI_NAME="eagleGPT"
EOF

echo "🏗️ Building patched image..."
docker build -f Dockerfile.patch -t eaglegpt:patched .

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    echo "💾 Saving image..."
    docker save eaglegpt:patched -o /tmp/eaglegpt-patched.tar
    
    echo "📤 Transferring to server..."
    cat /tmp/eaglegpt-patched.tar | docker --context $SERVER_CONTEXT load
    
    echo "🛑 Stopping old container..."
    docker --context $SERVER_CONTEXT stop eaglegpt 2>/dev/null || true
    docker --context $SERVER_CONTEXT rm eaglegpt 2>/dev/null || true
    
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
        eaglegpt:patched
    
    echo "⏳ Waiting for startup..."
    sleep 20
    
    echo "🔍 Verifying deployment..."
    curl -s http://95.217.152.30:3000/ | head -100 | grep -E "(eagleGPT|publicRoutes)" || echo "Check manually"
    
    echo "✅ Deployment complete!"
    
    # Cleanup
    rm -f /tmp/eaglegpt-patched.tar Dockerfile.patch
else
    echo "❌ Build failed"
fi