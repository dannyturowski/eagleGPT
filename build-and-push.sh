#!/bin/bash

# Build and push EagleGPT with demo mode

echo "Building EagleGPT with demo mode enabled..."

# Set build timestamp
BUILD_TIME=$(date +%Y%m%d-%H%M%S)

# Try building with reduced memory footprint
echo "Attempting optimized build..."

# First, let's try building just the frontend separately
echo "Building frontend..."
docker build --target build -t eaglegpt-frontend:temp -f Dockerfile .

if [ $? -ne 0 ]; then
    echo "Frontend build failed. Trying alternative approach..."
    
    # Alternative: Use pre-built OpenWebUI image and copy our files
    echo "Creating custom image based on official OpenWebUI..."
    
    cat > Dockerfile.custom << 'EOF'
FROM ghcr.io/open-webui/open-webui:main

# Copy our custom backend files
COPY --chown=0:0 ./backend/open_webui/routers/auths.py /app/backend/open_webui/routers/auths.py
COPY --chown=0:0 ./backend/open_webui/demo_auth_data.py /app/backend/open_webui/demo_auth_data.py
COPY --chown=0:0 ./backend/open_webui/utils/auth.py /app/backend/open_webui/utils/auth.py
COPY --chown=0:0 ./backend/open_webui/config.py /app/backend/open_webui/config.py
COPY --chown=0:0 ./backend/open_webui/main.py /app/backend/open_webui/main.py

# Copy our custom frontend files
COPY --chown=0:0 ./src/routes/+layout.svelte /app/src/routes/+layout.svelte
COPY --chown=0:0 ./src/lib/utils/demo.js /app/src/lib/utils/demo.js
COPY --chown=0:0 ./src/lib/components/chat/MessageInput.svelte /app/src/lib/components/chat/MessageInput.svelte
COPY --chown=0:0 ./src/lib/components/common/SettingsModal.svelte /app/src/lib/components/common/SettingsModal.svelte
COPY --chown=0:0 ./src/lib/apis/index.ts /app/src/lib/apis/index.ts

# Set environment variable
ENV ENABLE_DEMO_MODE=true

EOF

    # Build custom image
    docker build -f Dockerfile.custom -t ghcr.io/dannyturowski/eaglegpt:latest .
    
    if [ $? -ne 0 ]; then
        echo "Custom build also failed. Please check Docker resources."
        exit 1
    fi
else
    echo "Frontend build successful. Building full image..."
    docker build -t ghcr.io/dannyturowski/eaglegpt:latest .
fi

# Tag with version
docker tag ghcr.io/dannyturowski/eaglegpt:latest ghcr.io/dannyturowski/eaglegpt:demo-${BUILD_TIME}

echo "Pushing to GitHub Container Registry..."
docker push ghcr.io/dannyturowski/eaglegpt:latest
docker push ghcr.io/dannyturowski/eaglegpt:demo-${BUILD_TIME}

echo "Build and push complete!"
echo ""
echo "To deploy to the server, run:"
echo "ssh root@95.217.152.30"
echo "cd /root/eaglegpt"
echo "docker pull ghcr.io/dannyturowski/eaglegpt:latest"
echo "docker compose down && docker compose up -d"