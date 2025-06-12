#!/bin/bash

# Script to configure Docker client for insecure registry

echo "Configuring Docker to accept insecure registry at 95.217.152.30:5000"
echo ""
echo "This script will help you configure Docker to work with the private registry."
echo ""

# Check if running on WSL
if grep -q Microsoft /proc/version; then
    echo "⚠️  WSL Detected!"
    echo "For WSL2, you need to configure Docker Desktop:"
    echo ""
    echo "1. Open Docker Desktop"
    echo "2. Go to Settings → Docker Engine"
    echo "3. Add this to the JSON configuration:"
    echo ""
    echo '{'
    echo '  "insecure-registries": ["95.217.152.30:5000"]'
    echo '}'
    echo ""
    echo "4. Click 'Apply & Restart'"
    echo ""
    echo "Alternatively, if using Docker in WSL directly (not Docker Desktop),"
    echo "create or edit /etc/docker/daemon.json"
else
    # For Linux systems
    echo "For Linux systems, create or edit /etc/docker/daemon.json:"
    echo ""
    echo "sudo tee /etc/docker/daemon.json << 'EOF'"
    echo '{'
    echo '  "insecure-registries": ["95.217.152.30:5000"]'
    echo '}'
    echo 'EOF'
    echo ""
    echo "Then restart Docker:"
    echo "sudo systemctl restart docker"
fi

echo ""
echo "After configuration, you can test with:"
echo "docker pull 95.217.152.30:5000/registry-test:latest"