#!/bin/bash

echo "🔥 Hotfix Deployment for Anonymous Access"
echo "========================================="

SERVER_CONTEXT="hel1"

# Create a temporary directory for our patch
PATCH_DIR="/tmp/eaglegpt-hotfix-$$"
mkdir -p $PATCH_DIR

echo "📋 Copying fixed files..."
cp "src/routes/(app)/+layout.svelte" "$PATCH_DIR/app-layout.svelte"
cp "src/routes/+layout.svelte" "$PATCH_DIR/main-layout.svelte"

echo "🔧 Creating patch script..."
cat > "$PATCH_DIR/apply-patch.sh" << 'EOF'
#!/bin/bash
# This script runs inside the container
echo "Applying anonymous access fix..."

# Backup originals
cp /app/src/routes/\(app\)/+layout.svelte /app/src/routes/\(app\)/+layout.svelte.bak
cp /app/src/routes/+layout.svelte /app/src/routes/+layout.svelte.bak

# Apply patches
cp /tmp/patch/app-layout.svelte "/app/src/routes/(app)/+layout.svelte"
cp /tmp/patch/main-layout.svelte "/app/src/routes/+layout.svelte"

# Rebuild the app
cd /app
echo "Rebuilding frontend..."
npm run build

echo "Patch applied! Restarting in 5 seconds..."
sleep 5
EOF

chmod +x "$PATCH_DIR/apply-patch.sh"

echo "📦 Copying files to server..."
docker --context $SERVER_CONTEXT exec eaglegpt mkdir -p /tmp/patch
docker --context $SERVER_CONTEXT cp "$PATCH_DIR/app-layout.svelte" eaglegpt:/tmp/patch/
docker --context $SERVER_CONTEXT cp "$PATCH_DIR/main-layout.svelte" eaglegpt:/tmp/patch/
docker --context $SERVER_CONTEXT cp "$PATCH_DIR/apply-patch.sh" eaglegpt:/tmp/patch/

echo "🔨 Applying patch inside container..."
docker --context $SERVER_CONTEXT exec eaglegpt bash /tmp/patch/apply-patch.sh

echo "🔄 Restarting container..."
docker --context $SERVER_CONTEXT restart eaglegpt

echo "⏳ Waiting for container to restart..."
sleep 30

echo "🔍 Verifying deployment..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://95.217.152.30:3000/)
echo "HTTP Status: $HTTP_CODE"

echo "📝 Checking anonymous access..."
curl -s http://95.217.152.30:3000/ | head -200 | grep -q "publicRoutes" && echo "✅ Fix appears to be applied" || echo "⚠️  Fix may not be applied"

echo "🧹 Cleaning up..."
rm -rf $PATCH_DIR

echo ""
echo "✅ Hotfix deployment complete!"
echo "📋 Please test: https://eagleGPT.us in an incognito browser"
echo ""
echo "⚠️  This is a temporary fix. For a permanent solution:"
echo "1. Push your changes to GitHub"
echo "2. Let GitHub Actions build the image"
echo "3. Deploy from GHCR"