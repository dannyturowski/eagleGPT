#!/bin/bash

# Deploy EagleGPT directly on server
# This script copies files and builds on the server to avoid registry issues

set -e

echo "🚀 EagleGPT Server Deployment"
echo "============================"
echo ""

# Configuration
SERVER_CONTEXT="hel1"
REMOTE_DIR="/tmp/eaglegpt-build"
CONTAINER_NAME="eaglegpt"

# Step 1: Create a tarball of the project
echo "📦 Step 1: Creating project archive..."
tar -czf eaglegpt.tar.gz \
    --exclude=node_modules \
    --exclude=.git \
    --exclude=*.tar.gz \
    --exclude=backend/data \
    --exclude=backend/static \
    --exclude=backend/uploads \
    --exclude=.env \
    .

echo "✅ Archive created: eaglegpt.tar.gz"

# Step 2: Copy to server
echo ""
echo "📤 Step 2: Copying files to server..."
# First, get the server host from docker context
SERVER_HOST=$(docker context inspect ${SERVER_CONTEXT} | grep -o '"Host":"[^"]*"' | cut -d'"' -f4)
echo "Server host: ${SERVER_HOST}"

# Use docker cp through context to copy files
docker --context ${SERVER_CONTEXT} run --rm -v eaglegpt-build:/build alpine sh -c "mkdir -p /build"
# Note: This approach requires manual SCP. Let's use a different method.

echo ""
echo "📝 Manual steps required:"
echo "1. Copy eaglegpt.tar.gz to your server:"
echo "   scp eaglegpt.tar.gz root@${SERVER_HOST}:/tmp/"
echo ""
echo "2. SSH into your server:"
echo "   ssh root@${SERVER_HOST}"
echo ""
echo "3. On the server, run these commands:"
cat << 'EOF'
   # Extract files
   cd /tmp
   mkdir -p eaglegpt-build
   cd eaglegpt-build
   tar -xzf /tmp/eaglegpt.tar.gz
   
   # Build the image
   docker build -t eaglegpt:latest .
   
   # Stop and remove old container
   docker stop eaglegpt 2>/dev/null || true
   docker rm eaglegpt 2>/dev/null || true
   
   # Run new container
   docker run -d \
     --name eaglegpt \
     --restart unless-stopped \
     -p 3000:8080 \
     -v eaglegpt_data:/app/backend/data \
     eaglegpt:latest
   
   # Check status
   docker ps | grep eaglegpt
   docker logs eaglegpt
EOF

echo ""
echo "4. Clean up:"
echo "   rm -rf /tmp/eaglegpt-build /tmp/eaglegpt.tar.gz"