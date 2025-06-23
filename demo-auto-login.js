// Demo auto-login for anonymous users
(async function() {
    console.log('EagleGPT: Demo auto-login initializing');
    
    // Check if already authenticated or on auth page
    if (localStorage.getItem('token') || window.location.pathname === '/auth') {
        console.log('EagleGPT: User already authenticated or on auth page, skipping demo login');
        return;
    }
    
    // Check if we've already attempted demo login recently (prevent loops)
    const lastAttempt = localStorage.getItem('demo_login_attempt');
    if (lastAttempt) {
        const timeSinceAttempt = Date.now() - parseInt(lastAttempt);
        if (timeSinceAttempt < 5000) { // 5 second cooldown
            console.log('EagleGPT: Demo login attempted recently, waiting...');
            return;
        }
    }
    
    try {
        console.log('EagleGPT: Attempting demo auto-login for anonymous user');
        localStorage.setItem('demo_login_attempt', Date.now().toString());
        
        const response = await fetch('/api/v1/auths/demo', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        
        if (response.ok) {
            const data = await response.json();
            console.log('EagleGPT: Demo login successful');
            
            // Store the demo token
            localStorage.setItem('token', data.token);
            localStorage.setItem('demo_session', 'true');
            
            // Store user data if provided
            if (data.user) {
                localStorage.setItem('user', JSON.stringify(data.user));
            }
            
            // Remove the attempt timestamp on success
            localStorage.removeItem('demo_login_attempt');
            
            // Reload the page to initialize with demo user
            console.log('EagleGPT: Reloading page with demo credentials');
            window.location.reload();
        } else {
            console.error('EagleGPT: Demo login failed:', response.status, response.statusText);
            // Only redirect to auth if demo mode is explicitly disabled (403)
            if (response.status === 403) {
                const errorData = await response.json().catch(() => ({}));
                if (errorData.detail && errorData.detail.includes('Demo mode is not enabled')) {
                    console.log('EagleGPT: Demo mode disabled, redirecting to auth');
                    window.location.href = '/auth';
                }
            }
        }
    } catch (error) {
        console.error('EagleGPT: Demo auto-login error:', error);
        // Don't redirect on network errors - let the user see the interface
    }
    
    // Clean up old attempt timestamps periodically
    setTimeout(() => {
        const attempt = localStorage.getItem('demo_login_attempt');
        if (attempt && Date.now() - parseInt(attempt) > 60000) { // 1 minute old
            localStorage.removeItem('demo_login_attempt');
        }
    }, 10000);
})();