import { test, expect } from '@playwright/test';

test.describe('Send Button Functionality', () => {
  const baseURL = 'http://95.217.152.30:3000';

  test('Check send button state and user detection', async ({ page }) => {
    // Navigate to the site
    await page.goto(baseURL);
    
    // Wait for page to load
    await page.waitForLoadState('networkidle');
    
    // Wait a bit more for any JavaScript to initialize
    await page.waitForTimeout(3000);
    
    // Check current URL
    const currentUrl = page.url();
    console.log('Current URL:', currentUrl);
    
    // Try to access the user store from browser context
    const userInfo = await page.evaluate(() => {
      // Try different ways to access the user store
      const possibleStores = [
        window.__svelte_stores__,
        window.__sveltekit_stores__,
        window._app?.stores,
        window.stores
      ];
      
      for (const stores of possibleStores) {
        if (stores?.user) {
          const user = stores.user.get ? stores.user.get() : stores.user;
          return {
            found: true,
            user: user,
            isDemoCheck: {
              hasInfoField: !!user?.info,
              isDemoFlag: user?.info?.is_demo,
              userId: user?.id,
              userEmail: user?.email,
              isDemo: user?.info?.is_demo === true || user?.id === 'demo_eaglegpt_shared' || user?.email === 'demo@eaglegpt.us'
            }
          };
        }
      }
      
      // Try to find user in localStorage
      const token = localStorage.getItem('token');
      return {
        found: false,
        hasToken: !!token,
        stores: Object.keys(window).filter(key => key.includes('store') || key.includes('svelte'))
      };
    });
    
    console.log('User info:', JSON.stringify(userInfo, null, 2));
    
    // Check if we're on a chat page or need to create/select one
    if (currentUrl === baseURL + '/' || currentUrl === baseURL) {
      console.log('On home page, looking for new chat button');
      
      // Look for new chat button
      const newChatButton = await page.locator('button:has-text("New Chat"), button[id*="new-chat"], button[aria-label*="new chat"]').first();
      if (await newChatButton.isVisible()) {
        console.log('Found new chat button, clicking it');
        await newChatButton.click();
        await page.waitForTimeout(1000);
      }
    }
    
    // Now check the send button and input
    const messageInput = await page.locator('textarea, input[type="text"]').filter({ hasText: '' }).first();
    const sendButton = await page.locator('button[id*="send"], button[type="submit"], button:has(svg)').filter({ hasNotText: /New Chat|Settings|Sign/ }).first();
    
    console.log('UI Elements:');
    console.log('- Message input visible:', await messageInput.isVisible().catch(() => false));
    console.log('- Send button visible:', await sendButton.isVisible().catch(() => false));
    console.log('- Send button enabled:', await sendButton.isEnabled().catch(() => false));
    
    // Check placeholder text for clues
    if (await messageInput.isVisible()) {
      const placeholder = await messageInput.getAttribute('placeholder');
      console.log('- Input placeholder:', placeholder);
      
      // "Sign in to start chatting" means user store is empty
      if (placeholder?.toLowerCase().includes('sign in')) {
        console.log('⚠️  User store appears to be empty - users cannot send messages!');
      }
    }
    
    // Try to get button disabled state
    if (await sendButton.isVisible()) {
      const isDisabled = await sendButton.isDisabled();
      const className = await sendButton.getAttribute('class');
      console.log('- Send button disabled attribute:', isDisabled);
      console.log('- Send button classes:', className);
      
      if (isDisabled) {
        console.log('❌ Send button is disabled - users cannot send messages!');
      } else {
        console.log('✅ Send button is enabled');
      }
    }
  });
});