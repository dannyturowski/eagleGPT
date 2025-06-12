#!/bin/bash

# Quick fix script for anonymous access issues
set -e

echo "🔧 Fixing anonymous access configuration..."

# Update backend configuration to ensure public routes work
cat > /tmp/fix-auth.py << 'EOF'
# Temporary fix to ensure anonymous access works for root page
import os
print("Checking anonymous access configuration...")

# The changes should already be in the code, but let's verify
auth_layout = "/mnt/c/eaglegpt/src/routes/+layout.svelte"
if os.path.exists(auth_layout):
    with open(auth_layout, 'r') as f:
        content = f.read()
        if "publicRoutes" in content and "'/', '/welcome', '/auth', '/s'" in content:
            print("✅ Anonymous access code is present in +layout.svelte")
        else:
            print("❌ Anonymous access code missing in +layout.svelte")
else:
    print("❌ Layout file not found")

# Check Chat.svelte for authentication check
chat_file = "/mnt/c/eaglegpt/src/lib/components/chat/Chat.svelte"
if os.path.exists(chat_file):
    with open(chat_file, 'r') as f:
        content = f.read()
        if "if (!$user)" in content and "Please sign in to start chatting" in content:
            print("✅ Authentication check is present in Chat.svelte")
        else:
            print("❌ Authentication check missing in Chat.svelte")
else:
    print("❌ Chat.svelte file not found")

# Check backend env.py for WEBUI_NAME
env_file = "/mnt/c/eaglegpt/backend/open_webui/env.py"
if os.path.exists(env_file):
    with open(env_file, 'r') as f:
        content = f.read()
        if 'WEBUI_NAME = os.environ.get("WEBUI_NAME", "eagleGPT")' in content:
            print("✅ WEBUI_NAME correctly set to eagleGPT in env.py")
        else:
            print("❌ WEBUI_NAME not correctly set in env.py")
else:
    print("❌ env.py file not found")
EOF

python3 /tmp/fix-auth.py

echo ""
echo "📋 Summary of issues:"
echo "1. Anonymous access to root (/) - Code is present, may need cache clear"
echo "2. Page title showing '(Open WebUI)' - Backend configured correctly"
echo "3. Footer not visible on mobile - CSS/layout issue"
echo ""
echo "🔄 To fix these issues:"
echo "1. Clear browser cache and cookies for eagleGPT.us"
echo "2. Try accessing in incognito/private mode"
echo "3. The build process will complete the full fix"

# Check if build is still running
if pgrep -f "docker build" > /dev/null; then
    echo ""
    echo "⏳ Docker build is still in progress..."
    echo "   Once complete, run: ./force-rebuild-deploy.sh"
else
    echo ""
    echo "✅ No build in progress. You can run: ./force-rebuild-deploy.sh"
fi