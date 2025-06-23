// Comprehensive removal of anonymous showcase page
(function() {
    console.log('EagleGPT: Removing anonymous showcase page content');
    
    // Helper to check if user is authenticated or in demo mode
    function isAuthenticated() {
        return !!localStorage.getItem('token') || !!localStorage.getItem('demo_session');
    }
    
    // Function to aggressively remove anonymous content
    function removeAnonymousContent() {
        // Remove any element containing the specific text
        const textsToRemove = [
            'Welcome to eagleGPT',
            'Explore example conversations',
            'sign up to start your own',
            'This is a preview mode',
            'Sign In to Chat',
            'Select a Model',
            'Example Conversations',
            'Sign Up to Start Your Own Conversation'
        ];
        
        // Find and remove elements containing these texts
        textsToRemove.forEach(text => {
            const walker = document.createTreeWalker(
                document.body,
                NodeFilter.SHOW_TEXT,
                null,
                false
            );
            
            let node;
            while (node = walker.nextNode()) {
                if (node.nodeValue && node.nodeValue.includes(text)) {
                    // Find the parent container and hide it
                    let parent = node.parentElement;
                    while (parent && parent !== document.body) {
                        // Check if this is a major container
                        const classList = parent.className || '';
                        if (classList.includes('flex-col') || 
                            classList.includes('container') ||
                            classList.includes('w-full') ||
                            parent.tagName === 'MAIN' ||
                            parent.tagName === 'SECTION') {
                            parent.style.display = 'none';
                            console.log('EagleGPT: Removed container with text:', text);
                            break;
                        }
                        parent = parent.parentElement;
                    }
                }
            }
        });
        
        // Remove specific classes that might be anonymous content
        const selectorsToRemove = [
            '[class*="preview"]',
            '[class*="showcase"]',
            '[class*="anonymous"]',
            '[class*="example-conversation"]',
            '.bg-blue-600.text-white', // Welcome banner
            '[class*="Select a Model"]',
            '[class*="Example Conversations"]'
        ];
        
        selectorsToRemove.forEach(selector => {
            try {
                document.querySelectorAll(selector).forEach(el => {
                    if (el.textContent && (
                        el.textContent.includes('Welcome to eagleGPT') ||
                        el.textContent.includes('preview mode') ||
                        el.textContent.includes('Example Conversations')
                    )) {
                        el.remove();
                    }
                });
            } catch (e) {
                // Ignore selector errors
            }
        });
        
        // Hide any accordion or thread showcase elements
        document.querySelectorAll('[class*="accordion"], [class*="thread"]').forEach(el => {
            if (el.textContent && el.textContent.includes('Example')) {
                el.style.display = 'none';
            }
        });
    }
    
    // Run removal immediately
    removeAnonymousContent();
    
    // Monitor for changes
    const observer = new MutationObserver((mutations) => {
        // Check if any new nodes contain anonymous content
        for (let mutation of mutations) {
            if (mutation.type === 'childList') {
                removeAnonymousContent();
            }
        }
    });
    
    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
    
    // Also run on various events
    window.addEventListener('load', removeAnonymousContent);
    window.addEventListener('popstate', removeAnonymousContent);
    
    // Run periodically to catch any delayed content
    setInterval(removeAnonymousContent, 1000);
    
    // Override any Svelte store or component that might show anonymous content
    if (window.__svelte__) {
        console.log('EagleGPT: Attempting to override Svelte components');
        // This would need to be more specific based on the actual Svelte implementation
    }
})();