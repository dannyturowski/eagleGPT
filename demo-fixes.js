// Additional fixes for demo mode
(function() {
    console.log('EagleGPT: Applying demo mode fixes');
    
    // Override the submitPrompt function to check demo restrictions first
    const originalSubmitPrompt = window.submitPrompt;
    if (originalSubmitPrompt) {
        window.submitPrompt = async function(userPrompt, options) {
            // Check if demo user
            const user = JSON.parse(localStorage.getItem('user') || '{}');
            if (user.id && user.id.startsWith('demo_')) {
                console.log('Demo user attempted to send message');
                
                // Show toast notification
                if (window.Toastify) {
                    window.Toastify({
                        text: "Demo users cannot send messages. Sign up for full access!",
                        duration: 5000,
                        close: true,
                        gravity: "top",
                        position: "right",
                        backgroundColor: "#ef4444",
                        onClick: function() {
                            window.location.href = '/auth';
                        }
                    }).showToast();
                } else {
                    alert('Demo users cannot send messages. Please sign up for full access!');
                }
                return;
            }
            
            // Call original function
            return originalSubmitPrompt.call(this, userPrompt, options);
        };
    }
    
    // Monitor for chat creation attempts
    const originalFetch = window.fetch;
    window.fetch = async function(url, options) {
        // Intercept chat creation attempts
        if (url.includes('/api/v1/chats/new') && options && options.method === 'POST') {
            const user = JSON.parse(localStorage.getItem('user') || '{}');
            if (user.id && user.id.startsWith('demo_')) {
                console.log('Demo user attempted to create chat - blocked');
                
                // Return a fake successful response to prevent errors
                return {
                    ok: false,
                    status: 403,
                    statusText: 'Forbidden',
                    json: async () => ({ 
                        detail: 'Demo users cannot create new chats. Please sign up for a full account.' 
                    }),
                    text: async () => 'Demo users cannot create new chats'
                };
            }
        }
        
        return originalFetch.apply(this, arguments);
    };
})();