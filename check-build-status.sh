#!/bin/bash

echo "🔍 Checking Docker build status..."
echo "================================="
echo ""

# Check if docker build is running
if ps aux | grep -v grep | grep -q "docker build"; then
    echo "🏗️  Build is still in progress..."
    echo ""
    echo "Recent Docker processes:"
    ps aux | grep docker | grep -v grep | tail -5
else
    echo "✅ No active Docker build found"
    echo ""
    echo "Checking for eaglegpt images:"
    docker images | grep -E "(eaglegpt|REPOSITORY)" || echo "No eaglegpt images found yet"
fi

echo ""
echo "💡 Tips:"
echo "- The build typically takes 10-15 minutes"
echo "- You can monitor disk usage with: df -h"
echo "- Check Docker logs with: docker logs $(docker ps -q -n 1)"
echo ""
echo "Once the build completes, run: ./deploy-to-server.sh"