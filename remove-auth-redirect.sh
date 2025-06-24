#!/bin/bash

echo "Removing auth redirect from layout..."

# Create a patched version of the layout file
cat > /tmp/layout-patch.svelte << 'EOF'
		// Wait for user store to be initialized before redirecting
		if ($user === undefined) {
			// User state not loaded yet, wait
			await new Promise(resolve => setTimeout(resolve, 100));
		}
		
		// REMOVED: Auth redirect for anonymous users
		// Allow anonymous users to view the homepage
		if ($user && ['user', 'admin'].includes($user?.role)) {
EOF

# Copy the file to server and patch it
scp /tmp/layout-patch.svelte root@95.217.152.30:/tmp/

ssh root@95.217.152.30 << 'SSHEOF'
# Get the current layout file from container
docker cp eaglegpt:/app/src/routes/\(app\)/+layout.svelte /tmp/layout-original.svelte

# Create a backup
cp /tmp/layout-original.svelte /tmp/layout-backup.svelte

# Remove the auth redirect lines (lines 67-69)
sed -i '67,69d' /tmp/layout-original.svelte

# Also update line 69 (now 66) to remove the else
sed -i '66s/} else if/if/' /tmp/layout-original.svelte

# Copy back to container
docker cp /tmp/layout-original.svelte eaglegpt:/app/src/routes/\(app\)/+layout.svelte

# Restart container
docker restart eaglegpt

echo "Auth redirect removed and container restarted!"
SSHEOF

rm -f /tmp/layout-patch.svelte