#!/bin/bash
# Quick fix script to patch demo user info field in production container

echo "Applying demo user info field fix..."

# Copy the updated auth file to the container
docker cp /mnt/c/eaglegpt/backend/open_webui/routers/auths.py eaglegpt:/app/backend/open_webui/routers/auths.py

# Restart the container to apply changes
docker restart eaglegpt

echo "Fix applied. Waiting for container to restart..."
sleep 15

# Test the demo endpoint
echo "Testing demo endpoint..."
curl -X POST http://localhost:3000/api/v1/auths/demo -H "Content-Type: application/json" -s | jq '.'

echo "Done!"