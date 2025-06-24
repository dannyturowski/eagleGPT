# Demo Mode Implementation Plan for EagleGPT

## Current Situation
- Anonymous users are immediately redirected to /auth login page
- We have backend demo mode infrastructure ready but unused
- Users can't preview the interface without signing up

## Goal
Allow anonymous users to experience EagleGPT through a read-only demo mode that:
1. Auto-logs them in as a demo user
2. Shows the full OpenWebUI interface (not a separate landing page)  
3. Displays pre-populated patriotic chat threads
4. Blocks all write actions and redirects to signup

## Implementation Approach

### 1. Frontend Auto-Login Flow
```javascript
// On page load for anonymous users:
if (!localStorage.getItem('token') && window.location.pathname !== '/auth') {
    // Instead of redirecting to /auth, auto-login as demo user
    const response = await fetch('/api/v1/auths/demo', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'}
    });
    
    if (response.ok) {
        const data = await response.json();
        localStorage.setItem('token', data.token);
        // User store will update automatically with demo user
    }
}
```

### 2. Backend Demo Authentication (Already Implemented)
- **Endpoint**: `POST /api/v1/auths/demo`
- **Returns**: JWT token with `is_demo: true` flag
- **Demo User**: Virtual user with read-only permissions
- **Pre-populated Chats**: 5 patriotic conversation threads

### 3. Frontend Write Restrictions
Using `checkDemoRestriction()` from demo.js:
- Message Input: Block sending new messages
- New Chat Button: Redirect to signup
- Edit/Delete Actions: Show toast and redirect
- Settings Access: Blocked with signup prompt

### 4. Visual Indicators
- Subtle banner: "Preview Mode - Sign up to start your own conversations"
- All interactive elements remain visible but show signup prompt on click
- No separate UI - same interface as logged-in users

## Benefits of This Approach

1. **Low Friction Preview**: Users immediately see value without signup
2. **Authentic Experience**: Full interface, not a dumbed-down demo
3. **Clear Upgrade Path**: Every blocked action prompts signup
4. **No Separate Maintenance**: Uses same UI as regular users

## Technical Changes Needed

1. **Remove Current Redirect Script**
   - Delete aggressive auth redirect from remove-anonymous-page.js
   - Keep only the anonymous showcase content removal

2. **Add Demo Auto-Login Script**
   ```javascript
   // New demo-auto-login.js
   if (!authenticated && path !== '/auth') {
       autologinAsDemo();
   }
   ```

3. **Update Layout Component**
   - Remove hard redirect to /auth
   - Allow demo users to access main interface

4. **Ensure Demo Restrictions Work**
   - Verify all write actions check isDemoUser()
   - Test that restrictions show proper signup prompts

## Questions for Review

1. Should demo users see all interface elements (even if restricted)?
2. How prominent should the "Preview Mode" indicator be?
3. Should we limit demo session duration?
4. Do we track demo user analytics separately?

## Next Steps
1. Review this approach for any issues
2. Implement frontend auto-login
3. Remove aggressive auth redirects
4. Test full demo flow
5. Deploy to production