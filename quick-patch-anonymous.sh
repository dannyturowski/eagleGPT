#!/bin/bash

echo "🔧 Quick patch for anonymous user layout"
echo "========================================"

SERVER_CONTEXT="hel1"

# Create patch files
cat > /tmp/layout-patch.svelte << 'EOF'
# This is a patch file - copy the actual content from src/routes/(app)/+layout.svelte
# The key changes are:
# 1. Remove {#if $user} wrapper around the app div
# 2. Add {#if $user} around Sidebar only
# 3. Fix the closing tags
EOF

echo "📤 Copying fixed layout to container..."
docker --context $SERVER_CONTEXT cp "src/routes/(app)/+layout.svelte" eaglegpt:"/app/src/routes/(app)/+layout.svelte"

echo "🔨 Rebuilding inside container..."
docker --context $SERVER_CONTEXT exec eaglegpt bash -c "cd /app && npm run build"

echo "🔄 Restarting container..."
docker --context $SERVER_CONTEXT restart eaglegpt

echo "⏳ Waiting for restart..."
sleep 20

echo "✅ Patch applied!"
echo "Test at https://eagleGPT.us in incognito mode"