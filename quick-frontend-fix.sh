#!/bin/bash

echo "Quick frontend fix - building minimal changes..."

# Create a directory for our patches
mkdir -p frontend-patches

# Create the updated layout file
cat > frontend-patches/layout.js << 'EOF'
// This is a placeholder for the compiled layout
// The actual file would be the compiled JavaScript
// For now, we'll use a different approach
EOF

# Since we can't easily rebuild the frontend, let's create a custom index.html
# that includes our demo mode initialization

echo "Creating custom initialization script..."

# Copy the current index.html from server
ssh root@95.217.152.30 "docker cp eaglegpt:/app/build/index.html /tmp/index.html && cat /tmp/index.html" > /tmp/index-original.html

# Create our custom script to inject
cat > /tmp/demo-init.js << 'EOF'
// Demo mode initialization
(function() {
    // Check if user is not authenticated
    const checkAuth = setInterval(function() {
        if (window.user && window.user.subscribe) {
            window.user.subscribe(function(userData) {
                if (!userData && window.config && window.config.enable_demo_mode) {
                    // Auto-login with demo credentials
                    fetch('/api/v1/auths/demo', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/json'}
                    })
                    .then(res => res.json())
                    .then(data => {
                        if (data.token) {
                            localStorage.setItem('token', data.token);
                            window.location.reload();
                        }
                    })
                    .catch(err => console.error('Demo auth failed:', err));
                }
            });
            clearInterval(checkAuth);
        }
    }, 100);
})();
EOF

# Inject our script into the HTML before the closing body tag
sed -i '/<\/body>/i <script src="/demo-init.js"></script>' /tmp/index-original.html

# Copy files to server
scp /tmp/index-original.html root@95.217.152.30:/tmp/index-patched.html
scp /tmp/demo-init.js root@95.217.152.30:/tmp/demo-init.js

# Deploy to container
ssh root@95.217.152.30 << 'SSHEOF'
docker cp /tmp/index-patched.html eaglegpt:/app/build/index.html
docker cp /tmp/demo-init.js eaglegpt:/app/build/demo-init.js

# Also copy to static directory
docker cp /tmp/demo-init.js eaglegpt:/app/build/static/demo-init.js

echo "Frontend patched!"
SSHEOF

echo "Quick fix applied - testing..."
curl -s https://eaglegpt.us/ | grep -q "demo-init.js" && echo "Success!" || echo "Failed to apply patch"