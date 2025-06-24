#!/bin/bash

echo "Quick fix - removing anonymous showcase from existing setup..."

# Create a more aggressive patch
cat > /tmp/remove-anonymous.js << 'EOF'
// Aggressive removal of anonymous content
(function() {
    console.log('Removing anonymous showcase - aggressive mode');
    
    // Override the user store to always appear logged in for UI purposes
    if (window.user && window.user.subscribe) {
        // Create a fake user object
        const fakeUser = {
            id: 'demo',
            name: 'Demo User',
            email: 'demo@eaglegpt.us',
            role: 'user'
        };
        
        // Override the user store
        const originalSubscribe = window.user.subscribe;
        window.user.subscribe = function(callback) {
            // Always return a user object to prevent anonymous UI
            callback(fakeUser);
            return originalSubscribe.call(this, callback);
        };
        
        // Also set the user value directly if possible
        if (window.user.set) {
            window.user.set(fakeUser);
        }
    }
    
    // Remove any elements that might show anonymous content
    function removeAnonymous() {
        // Remove preview banners
        document.querySelectorAll('.bg-blue-600.text-white').forEach(el => {
            if (el.textContent.includes('preview') || el.textContent.includes('Welcome')) {
                el.remove();
            }
        });
        
        // Remove any showcase or anonymous specific content
        document.querySelectorAll('[class*="showcase"], [class*="anonymous"], [class*="thread"], [class*="accordion"]').forEach(el => {
            if (el.textContent && (
                el.textContent.includes('Sign In to Chat') ||
                el.textContent.includes('preview mode') ||
                el.textContent.includes('Popular Threads')
            )) {
                el.style.display = 'none';
            }
        });
        
        // Hide any auth prompts in main content area
        const mainContent = document.querySelector('main, #main, .main');
        if (mainContent) {
            const authPrompts = mainContent.querySelectorAll('button, a');
            authPrompts.forEach(el => {
                if (el.textContent && el.textContent.includes('Sign In')) {
                    el.closest('div')?.remove();
                }
            });
        }
    }
    
    // Run immediately
    removeAnonymous();
    
    // Run on DOM changes
    const observer = new MutationObserver(removeAnonymous);
    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
    
    // Run periodically to catch any delayed content
    setInterval(removeAnonymous, 500);
})();
EOF

# Deploy the patch
scp /tmp/remove-anonymous.js root@95.217.152.30:/tmp/

ssh root@95.217.152.30 << 'SSHEOF'
# First, let's use the existing eaglegpt image
docker stop eaglegpt 2>/dev/null || true
docker rm eaglegpt 2>/dev/null || true

# Start using the existing image
cd /opt/openwebui
docker run -d \
  --name eaglegpt \
  --restart unless-stopped \
  -p 3000:8080 \
  -v /mnt/HC_Volume_102716551/openwebui/data:/app/backend/data \
  -v /mnt/HC_Volume_102716551/openwebui/backup:/app/backup \
  -e ENABLE_DEMO_MODE=true \
  -e WEBUI_NAME=eagleGPT \
  ghcr.io/dannyturowski/eaglegpt:latest

# Wait for it to start
sleep 10

# Apply our patches
docker cp /tmp/remove-anonymous.js eaglegpt:/app/build/

# Update index.html to include the patch
docker exec eaglegpt sh -c "sed -i '/<\/body>/i <script src=\"/remove-anonymous.js\"></script>' /app/build/index.html"

echo "Patch applied!"
SSHEOF

echo "Quick fix complete!"