#!/bin/bash

echo "Deploying fix to completely remove anonymous showcase page..."

# Copy the new patch to server
scp remove-anonymous-page.js root@95.217.152.30:/tmp/

ssh root@95.217.152.30 << 'SSHEOF'
# Copy the patch into the container
docker cp /tmp/remove-anonymous-page.js eaglegpt:/app/build/

# Remove old patches that aren't working
docker exec eaglegpt rm -f /app/build/demo-init.js /app/build/remove-anonymous.js

# Update index.html to use only the new comprehensive patch
docker exec eaglegpt sh -c "cp /app/build/index.html /app/build/index.html.bak2"

# Remove old script tags
docker exec eaglegpt sh -c "sed -i '/<script src=\"\/demo-init.js\"><\/script>/d' /app/build/index.html"
docker exec eaglegpt sh -c "sed -i '/<script src=\"\/remove-anonymous.js\"><\/script>/d' /app/build/index.html"
docker exec eaglegpt sh -c "sed -i '/<script src=\"\/runtime-patch.js\"><\/script>/d' /app/build/index.html"

# Add the new comprehensive patch
docker exec eaglegpt sh -c "sed -i '/<\/body>/i <script src=\"/remove-anonymous-page.js\"></script>' /app/build/index.html"

# Also add an inline script for immediate execution
docker exec eaglegpt sh -c "sed -i '/<\/body>/i <script>if(!localStorage.getItem(\"token\") && window.location.pathname !== \"/auth\"){window.location.href=\"/auth\";}</script>' /app/build/index.html"

echo "Fix deployed! The site should now:"
echo "- Redirect all unauthenticated users to /auth"
echo "- Completely remove any anonymous showcase content"
echo "- Prevent the anonymous page from rendering"
SSHEOF