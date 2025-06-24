#!/bin/bash

echo "Deploying clean OpenWebUI with demo mode..."

# Create deployment files
cat > docker-compose.clean.yml << 'EOF'
services:
  eaglegpt:
    image: ghcr.io/open-webui/open-webui:main
    container_name: eaglegpt
    restart: unless-stopped
    environment:
      - WEBUI_SECRET_KEY=${OWEBUI_SECRET_KEY}
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - ENABLE_DEMO_MODE=true
      - WEBUI_NAME=eagleGPT
      - WEBUI_URL=https://eaglegpt.us
    volumes:
      - /mnt/HC_Volume_102716551/openwebui/data:/app/backend/data
      - /mnt/HC_Volume_102716551/openwebui/backup:/app/backup
    ports:
      - "3000:8080"

volumes:
  data:
  backup:
EOF

# Copy demo auth files
echo "Copying demo auth files..."
scp backend/open_webui/demo_auth_data.py root@95.217.152.30:/tmp/
scp backend/open_webui/routers/auths.py root@95.217.152.30:/tmp/
scp backend/open_webui/utils/auth.py root@95.217.152.30:/tmp/
scp backend/open_webui/config.py root@95.217.152.30:/tmp/
scp backend/open_webui/main.py root@95.217.152.30:/tmp/
scp docker-compose.clean.yml root@95.217.152.30:/opt/openwebui/

# Deploy on server
ssh root@95.217.152.30 << 'SSHEOF'
cd /opt/openwebui

# Stop current container
echo "Stopping current container..."
docker stop eaglegpt
docker rm eaglegpt

# Pull fresh OpenWebUI image
echo "Pulling fresh OpenWebUI image..."
docker pull ghcr.io/open-webui/open-webui:main

# Start with clean compose file
echo "Starting clean container..."
docker compose -f docker-compose.clean.yml up -d

# Wait for container to be ready
echo "Waiting for container to start..."
sleep 10

# Apply demo mode files
echo "Applying demo mode backend..."
docker cp /tmp/demo_auth_data.py eaglegpt:/app/backend/open_webui/
docker cp /tmp/auths.py eaglegpt:/app/backend/open_webui/routers/
docker cp /tmp/auth.py eaglegpt:/app/backend/open_webui/utils/
docker cp /tmp/config.py eaglegpt:/app/backend/open_webui/
docker cp /tmp/main.py eaglegpt:/app/backend/open_webui/

# Restart to apply changes
echo "Restarting with demo mode..."
docker restart eaglegpt

echo "Clean deployment complete!"
echo "The site should now show the standard OpenWebUI interface without anonymous showcase."
SSHEOF