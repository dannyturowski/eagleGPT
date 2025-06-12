#!/bin/bash

# Deploy eaglegpt respecting existing configuration
set -e

echo "🚀 EagleGPT Deploy (Respecting Existing Config)"
echo "=============================================="
echo ""

SERVER_CONTEXT="hel1"
IMAGE_NAME="eaglegpt"
IMAGE_FILE="/tmp/eaglegpt-image.tar"
OPENWEBUI_DIR="/opt/openwebui"

# Step 1: Check existing configuration
echo "📋 Step 1: Checking existing configuration..."
echo "Looking for docker-compose.yml in ${OPENWEBUI_DIR}..."

# Get the docker-compose configuration
COMPOSE_CONFIG=$(docker --context ${SERVER_CONTEXT} run --rm -v ${OPENWEBUI_DIR}:/config alpine cat /config/docker-compose.yml 2>/dev/null)

if [ -z "$COMPOSE_CONFIG" ]; then
    echo "❌ No docker-compose.yml found at ${OPENWEBUI_DIR}"
    exit 1
fi

echo "✅ Found existing configuration"
echo ""
echo "Current volume mappings:"
echo "$COMPOSE_CONFIG" | grep -A2 "volumes:" | tail -2

# Step 2: Build the image locally
echo ""
echo "📦 Step 2: Building Docker image locally..."
docker build -t ${IMAGE_NAME}:latest . --progress=plain

if [ $? -ne 0 ]; then
    echo "❌ Build failed!"
    exit 1
fi

echo "✅ Build completed successfully!"

# Step 3: Save and transfer
echo ""
echo "💾 Step 3: Saving and transferring image..."
docker save ${IMAGE_NAME}:latest -o ${IMAGE_FILE}
IMAGE_SIZE=$(du -h ${IMAGE_FILE} | cut -f1)
echo "Image size: ${IMAGE_SIZE}"

cat ${IMAGE_FILE} | docker --context ${SERVER_CONTEXT} load
echo "✅ Image loaded on server!"

# Step 4: Stop existing container
echo ""
echo "🛑 Step 4: Stopping existing container..."
docker --context ${SERVER_CONTEXT} stop eaglegpt 2>/dev/null || true
docker --context ${SERVER_CONTEXT} rm eaglegpt 2>/dev/null || true

# Step 5: Get environment variables from .env if exists
echo ""
echo "🔐 Step 5: Loading environment configuration..."
ENV_VARS=""
if docker --context ${SERVER_CONTEXT} run --rm -v ${OPENWEBUI_DIR}:/config alpine test -f /config/.env; then
    echo "Found .env file, loading variables..."
    ENV_FILE_CONTENT=$(docker --context ${SERVER_CONTEXT} run --rm -v ${OPENWEBUI_DIR}:/config alpine cat /config/.env)
    
    # Parse key environment variables
    WEBUI_SECRET_KEY=$(echo "$ENV_FILE_CONTENT" | grep "WEBUI_SECRET_KEY=" | cut -d'=' -f2-)
    
    if [ -n "$WEBUI_SECRET_KEY" ]; then
        ENV_VARS="-e WEBUI_SECRET_KEY=\"$WEBUI_SECRET_KEY\""
    else
        ENV_VARS="-e WEBUI_SECRET_KEY=\"$(openssl rand -hex 32)\""
    fi
else
    echo "No .env file found, using defaults"
    ENV_VARS="-e WEBUI_SECRET_KEY=\"$(openssl rand -hex 32)\""
fi

# Step 6: Run with proper configuration
echo ""
echo "🚀 Step 6: Starting eaglegpt with existing configuration..."

# Run the container with bind mounts matching docker-compose
docker --context ${SERVER_CONTEXT} run -d \
    --name eaglegpt \
    --restart unless-stopped \
    -p 3000:8080 \
    -v ${OPENWEBUI_DIR}/data:/app/backend/data \
    -v ${OPENWEBUI_DIR}/backup:/app/backup \
    -e WEBUI_NAME="eagleGPT" \
    -e WEBUI_URL="http://95.217.152.30:3000" \
    -e ENABLE_SIGNUP="true" \
    $ENV_VARS \
    ${IMAGE_NAME}:latest

# Step 7: Verify
echo ""
echo "🔍 Step 7: Verifying deployment..."
sleep 5

if docker --context ${SERVER_CONTEXT} ps | grep -q eaglegpt; then
    echo "✅ eaglegpt is running!"
    echo ""
    echo "📋 Container status:"
    docker --context ${SERVER_CONTEXT} ps | grep eaglegpt
    echo ""
    echo "📝 Data directory contents:"
    docker --context ${SERVER_CONTEXT} run --rm -v ${OPENWEBUI_DIR}/data:/data alpine ls -la /data | head -10
else
    echo "❌ eaglegpt failed to start!"
    docker --context ${SERVER_CONTEXT} logs eaglegpt
    exit 1
fi

# Cleanup
rm -f ${IMAGE_FILE}

echo ""
echo "🎉 Deployment complete!"
echo "🌐 Access eagleGPT at: http://95.217.152.30:3000"
echo ""
echo "📁 Data location: ${OPENWEBUI_DIR}/data"
echo "📁 Backup location: ${OPENWEBUI_DIR}/backup"
echo ""
echo "⚠️  IMPORTANT: This deployment uses bind mounts to:"
echo "   - ${OPENWEBUI_DIR}/data"
echo "   - ${OPENWEBUI_DIR}/backup"
echo "   These directories contain your persistent data!"
echo ""
echo "📝 Useful commands:"
echo "   Check logs: docker --context ${SERVER_CONTEXT} logs eaglegpt -f"
echo "   Restart: docker --context ${SERVER_CONTEXT} restart eaglegpt"
echo "   Stop: docker --context ${SERVER_CONTEXT} stop eaglegpt"