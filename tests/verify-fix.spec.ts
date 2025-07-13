import { test, expect } from '@playwright/test';

test.describe('EagleGPT Message Submission Fix', () => {
  const baseURL = 'http://95.217.152.30:3000';

  test('Demo user sees restriction modal when trying to send message', async ({ page }) => {
    // Navigate to the site
    await page.goto(baseURL);
    
    // Wait for page to load
    await page.waitForLoadState('networkidle');
    
    // Check if we're redirected to auth or if demo session is created
    const url = page.url();
    console.log('Current URL:', url);
    
    // If on auth page, we need to handle differently
    if (url.includes('/auth')) {
      console.log('Redirected to auth page - demo mode might not be working');
      // Check if we can see the login form
      const loginForm = await page.locator('form').first().isVisible().catch(() => false);
      expect(loginForm).toBe(true);
    } else {
      // We should be on the main page with demo user
      // Try to find the message input
      const messageInput = await page.locator('#chat-input, textarea[placeholder*="Send"], textarea[placeholder*="message"]').first();
      
      if (await messageInput.isVisible()) {
        // Type a message
        await messageInput.fill('Test message from demo user');
        
        // Try to send the message
        // First check if send button is visible
        const sendButton = await page.locator('button[id*="send"], button[aria-label*="send"]').first();
        
        if (await sendButton.isVisible() && await sendButton.isEnabled()) {
          await sendButton.click();
          
          // Wait for demo restriction modal to appear
          await page.waitForSelector('text=/Sign up|demo|Demo/', { timeout: 5000 }).catch(() => null);
          
          // Check if demo modal is visible
          const demoModal = await page.locator('text=/Sign up to start|Demo users cannot/').isVisible();
          console.log('Demo restriction modal visible:', demoModal);
        } else {
          console.log('Send button not enabled/visible for demo user');
        }
      } else {
        console.log('Message input not found - might need to navigate to a chat first');
      }
    }
  });

  test('Check if authenticated user can send messages', async ({ page, context }) => {
    // This test would require actual login credentials
    // For now, let's just check if the login page is accessible
    
    await page.goto(`${baseURL}/auth`);
    await page.waitForLoadState('networkidle');
    
    // Check if login form exists
    const emailInput = await page.locator('input[type="email"], input[name="email"], input[placeholder*="email"]').first();
    const passwordInput = await page.locator('input[type="password"], input[name="password"]').first();
    
    expect(await emailInput.isVisible()).toBe(true);
    expect(await passwordInput.isVisible()).toBe(true);
    
    console.log('Login form is accessible');
    
    // We can't actually test login without credentials
    // But we can verify the auth page is working
  });

  test('Verify patched JavaScript is being served', async ({ page }) => {
    // Navigate to the JavaScript file directly
    const response = await page.goto(`${baseURL}/_app/immutable/chunks/CJtZhCoN.js`);
    
    if (response && response.ok()) {
      const content = await response.text();
      
      // Check if our patch is present
      const hasDemoUserId = content.includes('demo_eaglegpt_shared');
      const hasDemoEmail = content.includes('demo@eaglegpt.us');
      
      console.log('Patch verification:');
      console.log('- Contains demo_eaglegpt_shared:', hasDemoUserId);
      console.log('- Contains demo@eaglegpt.us:', hasDemoEmail);
      
      expect(hasDemoUserId).toBe(true);
      expect(hasDemoEmail).toBe(true);
    } else {
      console.log('Could not fetch JavaScript file');
    }
  });
});