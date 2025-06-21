#!/bin/bash

# Build and deploy EagleGPT with demo mode enabled

echo "Building EagleGPT with demo mode enabled..."

# Build the Docker image
docker build -t ghcr.io/dannyturowski/eaglegpt:latest .

# Tag with version
docker tag ghcr.io/dannyturowski/eaglegpt:latest ghcr.io/dannyturowski/eaglegpt:demo-$(date +%Y%m%d-%H%M%S)

echo "Pushing to GitHub Container Registry..."
docker push ghcr.io/dannyturowski/eaglegpt:latest
docker push ghcr.io/dannyturowski/eaglegpt:demo-$(date +%Y%m%d-%H%M%S)

echo "Build and push complete!"
echo ""
echo "To deploy to the server, run:"
echo "ssh root@95.217.152.30"
echo "cd /root/eaglegpt"
echo "docker pull ghcr.io/dannyturowski/eaglegpt:latest"
echo "docker compose down && docker compose up -d"