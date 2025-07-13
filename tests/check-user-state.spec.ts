import { test, expect } from '@playwright/test';

test('Check current user state and UI elements', async ({ page }) => {
  console.log('=== Checking Current User State ===\n');
  
  // First check if anyone is currently logged in
  await page.goto('http://95.217.152.30:3000');
  await page.waitForLoadState('networkidle');
  
  const initialState = await page.evaluate(() => {
    const token = localStorage.getItem('token');
    if (token) {
      try {
        const parts = token.split('.');
        const payload = JSON.parse(atob(parts[1]));
        return {
          hasToken: true,
          userId: payload.id,
          userEmail: payload.email,
          isDemo: payload.id === 'demo_eaglegpt_shared',
          exp: payload.exp,
          expiresIn: new Date(payload.exp * 1000).toLocaleString()
        };
      } catch (e) {
        return { hasToken: true, error: e.message };
      }
    }
    return { hasToken: false };
  });
  
  console.log('Current session:', initialState);
  
  if (!initialState.hasToken) {
    console.log('No active session - testing demo mode\n');
    
    // Go to auth page and click demo button
    await page.goto('http://95.217.152.30:3000/auth');
    await page.waitForLoadState('networkidle');
    
    const demoButton = page.locator('button:has-text("Browse as Demo")');
    await demoButton.click();
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);
  }
  
  console.log('\nChecking UI elements:');
  
  // Check various UI elements
  const uiElements = await page.evaluate(() => {
    const elements = {
      chatInput: null,
      sendButton: null,
      userMenu: null,
      signOutButton: null
    };
    
    // Find chat input
    const chatInput = document.querySelector('#chat-input, [contenteditable="true"], textarea[placeholder*="message"]');
    if (chatInput) {
      elements.chatInput = {
        exists: true,
        type: chatInput.tagName,
        placeholder: chatInput.getAttribute('placeholder'),
        disabled: chatInput.hasAttribute('disabled'),
        contentEditable: chatInput.getAttribute('contenteditable')
      };
    }
    
    // Find send button
    const sendButton = document.querySelector('#send-message-button, button[aria-label*="send"], button svg[class*="paper-plane"]')?.closest('button');
    if (sendButton) {
      elements.sendButton = {
        exists: true,
        disabled: sendButton.disabled,
        className: sendButton.className,
        ariaLabel: sendButton.getAttribute('aria-label')
      };
    }
    
    // Find user menu
    const userMenuButton = document.querySelector('button img[alt*="profile"], button[aria-label*="user"], button[aria-label*="User"]')?.closest('button');
    if (userMenuButton) {
      elements.userMenu = {
        exists: true,
        text: userMenuButton.textContent?.trim()
      };
    }
    
    // Find sign out option
    const signOutLink = Array.from(document.querySelectorAll('a, button')).find(el => 
      el.textContent?.toLowerCase().includes('sign out') || 
      el.textContent?.toLowerCase().includes('log out')
    );
    if (signOutLink) {
      elements.signOutButton = {
        exists: true,
        text: signOutLink.textContent?.trim()
      };
    }
    
    return elements;
  });
  
  console.log('Chat input:', uiElements.chatInput);
  console.log('Send button:', uiElements.sendButton);
  console.log('User menu:', uiElements.userMenu);
  console.log('Sign out:', uiElements.signOutButton);
  
  // Test sending a message
  console.log('\nTesting message functionality:');
  
  const chatInput = page.locator('#chat-input, [contenteditable="true"], textarea[placeholder*="message"]').first();
  const sendButton = page.locator('#send-message-button, button[aria-label*="send"]').first();
  
  if (await chatInput.isVisible()) {
    await chatInput.click();
    await chatInput.fill('Test message');
    
    // Check send button state
    const isEnabled = await sendButton.isEnabled();
    console.log('Send button enabled after typing:', isEnabled);
    
    if (isEnabled) {
      console.log('✅ Send button is enabled - users should be able to send messages');
    } else {
      console.log('❌ Send button is disabled even after typing');
      
      // Check for any error messages or modals
      const errorText = await page.locator('.text-red-500, .error, .alert').first().textContent().catch(() => null);
      if (errorText) {
        console.log('Error message:', errorText);
      }
    }
    
    // Try clicking send button
    await sendButton.click();
    await page.waitForTimeout(2000);
    
    // Check if modal appeared
    const modalVisible = await page.locator('[role="dialog"], .modal').first().isVisible();
    if (modalVisible) {
      const modalText = await page.locator('[role="dialog"], .modal').first().textContent();
      console.log('\nModal appeared:', modalText.substring(0, 200));
      
      if (modalText.includes('Demo') || modalText.includes('Sign Up')) {
        console.log('❌ Demo restriction modal - user is treated as demo');
      }
    } else {
      console.log('✅ No modal - message should be processing');
      
      // Check for response
      const responseIndicator = await page.locator('.typing-indicator, [class*="loading"], [class*="generating"]').first().isVisible();
      if (responseIndicator) {
        console.log('✅ AI is generating response');
      }
    }
  }
  
  // Check the specific user state in the UI
  const userInfo = await page.evaluate(() => {
    // Check if user info is displayed anywhere
    const userElements = Array.from(document.querySelectorAll('*')).filter(el => 
      el.textContent?.includes('Demo User') || 
      el.textContent?.includes('demo@eaglegpt.us')
    );
    
    return {
      hasDemoText: userElements.length > 0,
      userStore: (window as any).user || (window as any)._user || null
    };
  });
  
  console.log('\nUser info in UI:', userInfo);
  
  console.log('\n=== Summary ===');
  if (initialState.hasToken && !initialState.isDemo) {
    console.log('✅ Regular user is logged in');
  } else if (initialState.isDemo) {
    console.log('⚠️  Demo user is active');
  } else {
    console.log('ℹ️  No user logged in');
  }
});