#!/bin/bash

echo "Fixing deployment - applying patches to running container..."

ssh root@95.217.152.30 << 'SSHEOF'
# Apply the patches to index.html
docker exec eaglegpt sh -c 'cp /app/build/index.html /app/build/index.html.bak'
docker exec eaglegpt sh -c 'sed -i "210i <script src=\"/demo-init.js\"></script>" /app/build/index.html'
docker exec eaglegpt sh -c 'sed -i "210i <script src=\"/remove-anonymous.js\"></script>" /app/build/index.html'

# Verify the patches were applied
echo "Verifying patches..."
docker exec eaglegpt grep -c "demo-init\|remove-anonymous" /app/build/index.html

# No need to restart since these are static files
echo "Patches applied! The site should now:"
echo "- Have demo mode authentication working"
echo "- Remove anonymous showcase content"
echo "- Auto-login anonymous users with demo credentials"
SSHEOF