import { test, expect } from '@playwright/test';

test('Debug user store and authentication', async ({ page }) => {
  // First, go to the auth page and try to log in
  await page.goto('http://95.217.152.30:3000/auth');
  await page.waitForLoadState('networkidle');
  
  console.log('=== Auth Page Check ===');
  console.log('URL:', page.url());
  
  // Check if login form exists
  const emailInput = await page.locator('input[type="email"], input[name="email"]').first();
  const passwordInput = await page.locator('input[type="password"]').first();
  
  if (await emailInput.isVisible() && await passwordInput.isVisible()) {
    console.log('Login form is visible');
    
    // Check current localStorage before login
    const beforeLogin = await page.evaluate(() => {
      return {
        hasToken: !!localStorage.getItem('token'),
        tokenLength: localStorage.getItem('token')?.length
      };
    });
    console.log('Before login - localStorage:', beforeLogin);
    
    // For this test, we'll just check what happens when we navigate away
    console.log('\n=== Navigating to main page ===');
    await page.goto('http://95.217.152.30:3000');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);
    
    // Check where we ended up
    const afterNavUrl = page.url();
    console.log('After navigation URL:', afterNavUrl);
    
    // Check localStorage again
    const afterNav = await page.evaluate(() => {
      const token = localStorage.getItem('token');
      if (token) {
        try {
          const parts = token.split('.');
          if (parts.length === 3) {
            const payload = JSON.parse(atob(parts[1]));
            return {
              hasToken: true,
              tokenPayload: payload,
              userId: payload.id,
              userEmail: payload.email,
              exp: payload.exp,
              isDemo: payload.id === 'demo_eaglegpt_shared'
            };
          }
        } catch (e) {
          return { hasToken: true, error: e.message };
        }
      }
      return { hasToken: false };
    });
    
    console.log('\n=== Token Analysis ===');
    console.log(JSON.stringify(afterNav, null, 2));
    
    // Now check what the JavaScript context thinks about the user
    const jsUserCheck = await page.evaluate(() => {
      // Try to access the user from different possible locations
      const checks = {
        documentCookie: document.cookie,
        localStorageKeys: Object.keys(localStorage),
        sessionStorageKeys: Object.keys(sessionStorage)
      };
      
      // Check if the patched isDemoUser function exists
      if (typeof window.isDemoUser === 'function') {
        checks.globalIsDemoUser = window.isDemoUser();
      }
      
      // Look for any user-related data in the DOM
      const userElements = document.querySelectorAll('[class*="user"], [id*="user"]');
      checks.userElementCount = userElements.length;
      
      // Check for specific text that indicates user state
      const bodyText = document.body.textContent || '';
      checks.containsDemoUser = bodyText.includes('Demo User');
      checks.containsSignIn = bodyText.includes('Sign in');
      checks.containsLogOut = bodyText.includes('Log out') || bodyText.includes('Logout');
      
      return checks;
    });
    
    console.log('\n=== JavaScript Context Check ===');
    console.log(JSON.stringify(jsUserCheck, null, 2));
    
    // Try to find and click on the chat input to trigger the demo check
    const chatInput = page.locator('#chat-input');
    if (await chatInput.isVisible()) {
      console.log('\n=== Testing Message Send ===');
      await chatInput.click();
      await chatInput.fill('Test message');
      
      const sendButton = page.locator('#send-message-button');
      if (await sendButton.isVisible()) {
        await sendButton.click();
        await page.waitForTimeout(2000);
        
        // Check what modal appeared
        const modalCheck = await page.evaluate(() => {
          const modals = document.querySelectorAll('[role="dialog"], .modal, [class*="modal"]');
          const modalInfo = [];
          
          modals.forEach(modal => {
            const text = modal.textContent || '';
            modalInfo.push({
              visible: modal.offsetWidth > 0 && modal.offsetHeight > 0,
              text: text.substring(0, 100),
              hasDemoText: text.includes('demo') || text.includes('Demo'),
              hasSignUpText: text.includes('Sign up') || text.includes('Sign Up')
            });
          });
          
          return modalInfo;
        });
        
        console.log('\n=== Modal Check ===');
        console.log(JSON.stringify(modalCheck, null, 2));
      }
    }
    
    // Final check: Look at the minified JS to see if our patch is there
    const jsFileCheck = await page.evaluate(async () => {
      try {
        const response = await fetch('/_app/immutable/chunks/CJtZhCoN.js');
        const text = await response.text();
        return {
          hasFile: true,
          length: text.length,
          hasDemoUserId: text.includes('demo_eaglegpt_shared'),
          hasDemoEmail: text.includes('demo@eaglegpt.us'),
          hasIsDemoCheck: text.includes('is_demo')
        };
      } catch (e) {
        return { hasFile: false, error: e.message };
      }
    });
    
    console.log('\n=== JavaScript File Check ===');
    console.log(JSON.stringify(jsFileCheck, null, 2));
  }
});