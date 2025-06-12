#!/bin/bash

echo "🔍 EagleGPT Server Status Check"
echo "=============================="
echo ""

# Check if builder is running
echo "📦 Build Status:"
if docker --context hel1 ps | grep -q eaglegpt-builder; then
    echo "🏗️  Build in progress..."
    echo ""
    echo "Recent build logs:"
    docker --context hel1 logs eaglegpt-builder --tail 10
else
    echo "✅ No active build"
fi

echo ""
echo "🐳 Docker Images on Server:"
docker --context hel1 images | grep -E "(eaglegpt|open-webui|REPOSITORY)" || echo "No eaglegpt images found"

echo ""
echo "📋 Running Containers:"
docker --context hel1 ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "💾 Server Disk Usage:"
docker --context hel1 run --rm alpine df -h / | tail -1

echo ""
echo "🌐 Server Info:"
echo "IP: 95.217.152.30"
echo "Port: 3000 (when deployed)"
echo "URL: http://95.217.152.30:3000"