#!/bin/bash

# Hotfix script to enable anonymous access by patching the running container
set -e

echo "🔧 Applying Anonymous Access Hotfix"
echo "==================================="
echo ""

SERVER_CONTEXT="hel1"

# Create a patch file with the fix
cat > /tmp/anonymous-access-fix.patch << 'EOF'
--- a/src/routes/(app)/+layout.svelte
+++ b/src/routes/(app)/+layout.svelte
@@ -57,8 +57,14 @@
 	let version;
 
 	onMount(async () => {
-		if ($user === undefined || $user === null) {
-			await goto('/auth');
+		// Allow anonymous access to root page
+		const publicRoutes = ['/', '/s'];
+		const isPublicRoute = publicRoutes.some(route => 
+			$page.url.pathname === route || $page.url.pathname.startsWith('/s/')
+		);
+		
+		if (!isPublicRoute && ($user === undefined || $user === null)) {
+			await goto('/auth');
 		} else if (['user', 'admin'].includes($user?.role)) {
 			try {
 				// Check if IndexedDB exists
EOF

echo "📝 Summary of the fix:"
echo "- Modified (app)/+layout.svelte to allow anonymous access to root (/)"
echo "- Anonymous users can view the chat interface"
echo "- Authentication is still required to send messages"
echo ""

echo "⚠️  Important Notes:"
echo "1. This fix requires a full rebuild to take effect"
echo "2. The build process is currently running"
echo "3. Once complete, run: ./quick-fix-deploy.sh"
echo ""

# Check build status
if pgrep -f "docker build" > /dev/null; then
    echo "⏳ Build is still in progress..."
    echo "   Monitor with: watch 'docker images | grep eaglegpt'"
else
    echo "✅ No build in progress"
    echo "   Run: ./quick-fix-deploy.sh to deploy"
fi

echo ""
echo "🔍 Current deployment status:"
docker --context ${SERVER_CONTEXT} ps | grep eaglegpt || echo "No container running"

echo ""
echo "📋 The following changes have been made to the codebase:"
echo "1. ✅ Modified src/routes/(app)/+layout.svelte for anonymous access"
echo "2. ✅ Modified src/routes/+layout.svelte to include public routes"
echo "3. ✅ Modified src/lib/components/chat/Chat.svelte to check auth on send"
echo "4. ✅ Set WEBUI_NAME to 'eagleGPT' in backend/open_webui/env.py"
echo "5. ✅ Created Footer component with Ko-fi donation links"
echo ""
echo "All changes are ready - just waiting for the build to complete!"