// Runtime patch to remove anonymous showcase
(function() {
    console.log('Applying runtime patch for anonymous showcase...');
    
    // Function to remove anonymous elements
    function removeAnonymousElements() {
        // Remove any anonymous showcase elements
        const showcaseElements = document.querySelectorAll('[class*="showcase"], [class*="anonymous"]');
        showcaseElements.forEach(el => {
            if (el.textContent.includes('preview mode') || 
                el.textContent.includes('Anonymous') ||
                el.textContent.includes('Welcome to eagleGPT')) {
                el.style.display = 'none';
            }
        });
        
        // Remove the blue banner for anonymous users
        const banners = document.querySelectorAll('.bg-blue-600.text-white');
        banners.forEach(banner => {
            if (banner.textContent.includes('preview mode')) {
                banner.remove();
            }
        });
        
        // Hide any thread accordions or showcase content
        const accordions = document.querySelectorAll('[class*="accordion"], [class*="thread"]');
        accordions.forEach(acc => {
            if (acc.querySelector && acc.querySelector('[class*="showcase"]')) {
                acc.style.display = 'none';
            }
        });
    }
    
    // Apply patch on DOM changes
    const observer = new MutationObserver(removeAnonymousElements);
    observer.observe(document.body, {
        childList: true,
        subtree: true
    });
    
    // Initial cleanup
    removeAnonymousElements();
    
    // Also patch after a delay to catch any late-loading content
    setTimeout(removeAnonymousElements, 1000);
    setTimeout(removeAnonymousElements, 3000);
})();