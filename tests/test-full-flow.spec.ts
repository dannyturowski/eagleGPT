import { test, expect } from '@playwright/test';

test.describe('Full User Flow Test', () => {
  const baseURL = 'http://95.217.152.30:3000';

  test('Test complete flow from landing to chat', async ({ page }) => {
    console.log('1. Navigating to site...');
    await page.goto(baseURL);
    await page.waitForLoadState('networkidle');
    
    const initialUrl = page.url();
    console.log('Initial URL:', initialUrl);
    
    // Take screenshot of initial state
    await page.screenshot({ path: 'test-results/1-initial-state.png' });
    
    // Check if we're on auth page or main page
    if (initialUrl.includes('/auth')) {
      console.log('2. On auth page - demo mode may not be enabled');
      
      // Check for demo mode elements
      const demoButton = await page.locator('button:has-text("Try Demo"), button:has-text("Continue as Guest"), button:has-text("Browse")').first();
      if (await demoButton.isVisible()) {
        console.log('Found demo button:', await demoButton.textContent());
        await demoButton.click();
        await page.waitForLoadState('networkidle');
      }
    }
    
    // Wait for any redirects to complete
    await page.waitForTimeout(2000);
    
    const currentUrl = page.url();
    console.log('3. Current URL after navigation:', currentUrl);
    
    // If we're on the main page, try to interact with chat
    if (!currentUrl.includes('/auth')) {
      console.log('4. On main page - checking for chat interface');
      
      // Look for the sidebar new chat button
      const sidebarNewChat = await page.locator('#sidebar-new-chat-button, button[aria-label*="new chat"], button:has-text("New Chat")').first();
      if (await sidebarNewChat.isVisible()) {
        console.log('Found sidebar new chat button');
        await sidebarNewChat.click();
        await page.waitForTimeout(1000);
      }
      
      // Check for message input
      const possibleInputs = [
        'textarea[placeholder*="Send"]',
        'textarea[placeholder*="message"]',
        'textarea[placeholder*="chat"]',
        'textarea#chat-input',
        'textarea',
        'input[type="text"][placeholder*="Send"]'
      ];
      
      let messageInput = null;
      for (const selector of possibleInputs) {
        const input = page.locator(selector).first();
        if (await input.isVisible()) {
          messageInput = input;
          console.log('5. Found message input with selector:', selector);
          const placeholder = await input.getAttribute('placeholder');
          console.log('   Placeholder text:', placeholder);
          
          // Critical check: if placeholder says "Sign in", user store is empty
          if (placeholder?.toLowerCase().includes('sign in')) {
            console.log('❌ CRITICAL: Placeholder says "Sign in" - user store is not populated!');
            console.log('   This means ALL users (including logged-in ones) cannot send messages.');
          }
          break;
        }
      }
      
      if (!messageInput) {
        console.log('❌ No message input found');
        await page.screenshot({ path: 'test-results/2-no-input-found.png' });
      } else {
        // Check send button
        const sendButton = await page.locator('button#send-message-button, button[aria-label*="send"], button[type="submit"]')
          .filter({ hasNotText: /Sign|Log|Settings/ })
          .first();
        
        if (await sendButton.isVisible()) {
          const isDisabled = await sendButton.isDisabled();
          const buttonText = await sendButton.textContent();
          const buttonClass = await sendButton.getAttribute('class');
          
          console.log('6. Send button state:');
          console.log('   Visible:', true);
          console.log('   Disabled:', isDisabled);
          console.log('   Text:', buttonText);
          console.log('   Class contains disabled:', buttonClass?.includes('disabled'));
          
          if (isDisabled) {
            console.log('❌ Send button is DISABLED - users cannot send messages!');
          } else {
            console.log('✅ Send button is enabled');
            
            // Try to type and send a message
            await messageInput.fill('Test message');
            await sendButton.click();
            
            // Wait to see what happens
            await page.waitForTimeout(2000);
            
            // Check for demo modal
            const demoModal = await page.locator('text=/Demo users cannot|Sign up to start/').isVisible();
            if (demoModal) {
              console.log('✅ Demo restriction modal appeared - demo user detection is working');
            } else {
              console.log('Message sent or no demo modal appeared');
            }
          }
        } else {
          console.log('❌ Send button not visible');
        }
        
        await page.screenshot({ path: 'test-results/3-final-state.png' });
      }
    } else {
      console.log('Still on auth page - cannot test chat functionality');
      await page.screenshot({ path: 'test-results/auth-page.png' });
    }
    
    // Final check: Try to evaluate JavaScript context
    const jsCheck = await page.evaluate(() => {
      try {
        // Check for user in localStorage token
        const token = localStorage.getItem('token');
        
        // Try to decode JWT token (basic decode, not verification)
        if (token) {
          const parts = token.split('.');
          if (parts.length === 3) {
            const payload = JSON.parse(atob(parts[1]));
            return {
              hasToken: true,
              tokenPayload: payload,
              isDemo: payload.id === 'demo_eaglegpt_shared'
            };
          }
        }
        
        return { hasToken: !!token, tokenPayload: null };
      } catch (e) {
        return { error: e.message };
      }
    });
    
    console.log('7. JavaScript context check:', JSON.stringify(jsCheck, null, 2));
  });
});