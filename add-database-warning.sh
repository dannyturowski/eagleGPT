#!/bin/bash

echo "Adding critical warning comment to docker-compose.yml..."

ssh root@95.217.152.30 << 'SSHEOF'
cd /opt/openwebui

# Backup current compose file
cp docker-compose.yml docker-compose.yml.backup

# Create updated docker-compose with critical warning
cat > docker-compose.yml << 'EOF'
# ⚠️  CRITICAL WARNING - DO NOT MODIFY VOLUME MOUNTS ⚠️
# 
# The database location /opt/openwebui/data contains ALL USER DATA including:
# - 7 registered users (Danny, Ev, Min, Jm, TabTabs, Elizabeth, John)
# - 27+ chat conversations with full history
# - User profiles, settings, and authentication data
#
# NEVER change the volume mount paths below or you will lose all user data!
# The correct database is ONLY at /opt/openwebui/data/webui.db
# 
# If you change these paths, users will appear to be missing and chat
# history will be lost. Always use /opt/openwebui/data as the source.
#
# Last verified: June 2025 - All 7 users confirmed in this database
# ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️ ⚠️

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
      # ⚠️ CRITICAL: This path contains all 7 users and 27+ chats - DO NOT CHANGE!
      - /opt/openwebui/data:/app/backend/data
      # ⚠️ CRITICAL: Backup location - DO NOT CHANGE!
      - /opt/openwebui/backup:/app/backup
    ports:
      - "3000:8080"

volumes:
  data:
  backup:

# ⚠️ REMINDER: The database at /opt/openwebui/data/webui.db contains:
# - Danny Turowski (admin)
# - Ev, Min, Jm, TabTabs, Elizabeth Paino, John Kirkland (users)
# - Full chat history and user settings
# 
# Any changes to volume mounts will break user access!
EOF

echo "Critical warning comments added to docker-compose.yml"
echo "The file now clearly warns against changing volume mount paths."
SSHEOF