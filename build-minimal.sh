#!/bin/bash

# Minimal build for demo mode - backend only

echo "Building minimal EagleGPT image with demo mode backend..."

BUILD_TIME=$(date +%Y%m%d-%H%M%S)

# Build the minimal image
docker build -f Dockerfile.minimal -t ghcr.io/dannyturowski/eaglegpt:minimal-demo .

if [ $? -eq 0 ]; then
    echo "Build successful!"
    
    # Tag it as latest
    docker tag ghcr.io/dannyturowski/eaglegpt:minimal-demo ghcr.io/dannyturowski/eaglegpt:latest
    docker tag ghcr.io/dannyturowski/eaglegpt:minimal-demo ghcr.io/dannyturowski/eaglegpt:demo-${BUILD_TIME}
    
    echo "Pushing to GHCR..."
    docker push ghcr.io/dannyturowski/eaglegpt:latest
    docker push ghcr.io/dannyturowski/eaglegpt:minimal-demo
    docker push ghcr.io/dannyturowski/eaglegpt:demo-${BUILD_TIME}
    
    echo ""
    echo "Successfully pushed minimal demo image!"
    echo ""
    echo "To deploy:"
    echo "ssh root@95.217.152.30"
    echo "cd /root/eaglegpt"
    echo "docker pull ghcr.io/dannyturowski/eaglegpt:latest"
    echo "docker compose down && docker compose up -d"
else
    echo "Build failed!"
    exit 1
fi