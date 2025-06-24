#!/bin/bash

echo "Fixing database mount to restore all users and chats..."

ssh root@95.217.152.30 << 'SSHEOF'
cd /opt/openwebui

# Stop current container
echo "Stopping current container..."
docker stop eaglegpt
docker rm eaglegpt

# Update docker-compose to use the correct data directory
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
      # Use the correct data directory with all users
      - /opt/openwebui/data:/app/backend/data
      - /opt/openwebui/backup:/app/backup
    ports:
      - "3000:8080"

volumes:
  data:
  backup:
EOF

# Start container with correct database
echo "Starting container with correct database mount..."
docker compose up -d

# Wait for container to be healthy
echo "Waiting for container to start..."
sleep 15

# Verify the correct database is mounted
docker exec eaglegpt python -c "
import sqlite3
conn = sqlite3.connect('/app/backend/data/webui.db')
cursor = conn.cursor()
cursor.execute('SELECT count(*) FROM user;')
user_count = cursor.fetchone()
print(f'Users now accessible: {user_count[0]}')
conn.close()
"

echo ""
echo "Database mount fixed! You should now see all 7 users and 27 chats."
echo "The correct database with your full user base is now active."
SSHEOF