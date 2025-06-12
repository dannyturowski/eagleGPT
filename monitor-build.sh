#!/bin/bash

# Monitor Docker build progress

echo "📊 Docker Build Monitor"
echo "======================"
echo ""

while true; do
    clear
    echo "📊 Docker Build Monitor - $(date)"
    echo "======================"
    echo ""
    
    # Check if build is running
    if ps aux | grep -v grep | grep -q "docker build"; then
        echo "🏗️  Build Status: IN PROGRESS"
        echo ""
        
        # Show disk usage
        echo "💾 Disk Usage:"
        df -h / | grep -v Filesystem
        echo ""
        
        # Show memory usage
        echo "🧠 Memory Usage:"
        free -h | grep -E "Mem:|Swap:"
        echo ""
        
        # Show Docker images
        echo "🐳 Docker Images:"
        docker images | head -5
        echo ""
        
        # Show last few lines of Docker daemon log if available
        if command -v journalctl >/dev/null 2>&1; then
            echo "📜 Recent Docker Activity:"
            journalctl -u docker -n 5 --no-pager 2>/dev/null || echo "Cannot access Docker logs"
        fi
        
    else
        echo "✅ Build Status: NOT RUNNING"
        echo ""
        
        # Check for eaglegpt image
        if docker images | grep -q "eaglegpt"; then
            echo "🎉 eaglegpt image found!"
            docker images | grep -E "(REPOSITORY|eaglegpt)"
            echo ""
            echo "Ready to deploy! Run: ./build-and-deploy.sh"
            break
        else
            echo "❌ No eaglegpt image found"
            echo ""
            echo "To start a build, run: docker build -t eaglegpt:latest ."
        fi
    fi
    
    echo ""
    echo "Press Ctrl+C to exit monitoring"
    sleep 5
done