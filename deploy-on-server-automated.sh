#!/bin/bash

# Automated deployment directly on server
# This builds and runs everything on the server

set -e

echo "🚀 EagleGPT Automated Server Deployment"
echo "======================================"
echo ""

SERVER_CONTEXT="hel1"
CONTAINER_NAME="eaglegpt"

# Step 1: Check if we can reach the server
echo "🔍 Checking server connection..."
if ! docker --context ${SERVER_CONTEXT} ps >/dev/null 2>&1; then
    echo "❌ Cannot connect to server context '${SERVER_CONTEXT}'"
    echo "Please ensure Docker context is properly configured"
    exit 1
fi
echo "✅ Server connection OK"

# Step 2: Clone the repository on the server
echo ""
echo "📦 Step 2: Setting up on server..."

# Create build script
cat > /tmp/build-eaglegpt.sh << 'EOF'
#!/bin/bash
set -e

# Stop and remove existing container
docker stop eaglegpt 2>/dev/null || true
docker rm eaglegpt 2>/dev/null || true

# Clone the repository
cd /tmp
rm -rf eaglegpt-build
git clone https://github.com/open-webui/open-webui.git eaglegpt-build
cd eaglegpt-build

# Build the image
echo "Building Docker image..."
docker build -t eaglegpt:latest . \
  --build-arg BUILD_HASH=$(git rev-parse --short HEAD) \
  --network host \
  --progress=plain

# Run the container
echo "Starting eaglegpt container..."
docker run -d \
  --name eaglegpt \
  --restart unless-stopped \
  -p 3000:8080 \
  -v eaglegpt-data:/app/backend/data \
  -e WEBUI_NAME="eagleGPT" \
  -e WEBUI_AUTH=true \
  eaglegpt:latest

# Check if running
sleep 5
if docker ps | grep -q eaglegpt; then
    echo "✅ eaglegpt is running!"
    docker logs eaglegpt --tail 20
else
    echo "❌ eaglegpt failed to start"
    docker logs eaglegpt
    exit 1
fi

# Cleanup
cd /
rm -rf /tmp/eaglegpt-build

echo "🎉 Deployment complete!"
EOF

# Step 3: Execute on server
echo "🚀 Step 3: Building and deploying on server..."
echo ""

# Copy and execute the script on the server
cat /tmp/build-eaglegpt.sh | docker --context ${SERVER_CONTEXT} run -i --rm \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /tmp:/tmp \
    --workdir /tmp \
    docker:cli sh -c "
        cat > /tmp/build-eaglegpt.sh
        chmod +x /tmp/build-eaglegpt.sh
        /tmp/build-eaglegpt.sh
    "

# Step 4: Show access information
echo ""
SERVER_IP=$(docker context inspect ${SERVER_CONTEXT} | grep -o '"Host":"[^"]*"' | cut -d'"' -f4 | cut -d':' -f1)
echo "🌐 Access your eaglegpt instance at: http://${SERVER_IP}:3000"
echo ""
echo "📝 To check logs: docker --context ${SERVER_CONTEXT} logs eaglegpt"
echo "🔄 To restart: docker --context ${SERVER_CONTEXT} restart eaglegpt"
echo "🛑 To stop: docker --context ${SERVER_CONTEXT} stop eaglegpt"

# Cleanup
rm -f /tmp/build-eaglegpt.sh