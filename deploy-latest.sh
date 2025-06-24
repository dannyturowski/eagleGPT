#!/bin/bash

echo "Deploying latest EagleGPT image with OpenWebUI v0.6.15..."

ssh root@95.217.152.30 << 'SSHEOF'
cd /opt/openwebui

# Backup current environment
cp .env .env.backup

# Stop and remove current container
echo "Stopping current container..."
docker stop eaglegpt
docker rm eaglegpt

# Pull the new image
echo "Pulling latest image..."
docker pull ghcr.io/dannyturowski/eaglegpt:latest

# Create updated docker-compose file
cat > docker-compose.yml << 'EOF'
services:
  eaglegpt:
    image: ghcr.io/dannyturowski/eaglegpt:latest
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

# Start the new container
echo "Starting new container..."
docker compose up -d

# Wait for container to be healthy
echo "Waiting for container to be healthy..."
for i in {1..30}; do
    if docker inspect eaglegpt | grep -q '"Status": "healthy"'; then
        echo "Container is healthy!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 2
done

# Show status
docker ps | grep eaglegpt
echo ""
echo "Deployment complete! Visit https://eaglegpt.us to verify."
echo "The site should now:"
echo "- Run OpenWebUI v0.6.15"
echo "- Have demo mode enabled"
echo "- Remove anonymous showcase via runtime patches"
echo "- Include demo authentication endpoint"
SSHEOF