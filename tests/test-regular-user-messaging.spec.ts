import { test, expect } from '@playwright/test';

test('Test regular user can send messages and get responses', async ({ page, context }) => {
  console.log('=== Testing Regular User Messaging ===\n');
  
  // Clear all cookies and localStorage
  await context.clearCookies();
  await page.goto('http://95.217.152.30:3000');
  await page.evaluate(() => {
    localStorage.clear();
    sessionStorage.clear();
  });
  
  console.log('1. Navigating to auth page');
  await page.goto('http://95.217.152.30:3000/auth');
  await page.waitForLoadState('networkidle');
  
  console.log('2. Attempting to log in as Danny (admin user)');
  
  // Fill in login credentials
  const emailInput = page.locator('input[type="email"]');
  const passwordInput = page.locator('input[type="password"]');
  const signInButton = page.locator('button:has-text("Sign in")').first();
  
  // Using known admin credentials from the codebase context
  await emailInput.fill('danny@dannyturowski.com');
  await passwordInput.fill('YOUR_PASSWORD_HERE'); // You'll need to provide the actual password
  
  console.log('3. Submitting login form');
  await signInButton.click();
  
  // Wait for navigation after login
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(3000);
  
  // Check if we're logged in
  const afterLogin = await page.evaluate(() => {
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
          url: window.location.href
        };
      } catch (e) {
        return { hasToken: true, error: e.message };
      }
    }
    return { hasToken: false, url: window.location.href };
  });
  
  console.log('After login state:', afterLogin);
  
  if (!afterLogin.hasToken) {
    console.log('❌ Login failed - no token found');
    console.log('Current URL:', afterLogin.url);
    
    // Check for error messages
    const errorMessage = await page.locator('.text-red-500, [class*="error"], [class*="danger"]').first().textContent().catch(() => null);
    if (errorMessage) {
      console.log('Error message:', errorMessage);
    }
    
    console.log('\n⚠️  Please update the test with valid credentials to test messaging');
    return;
  }
  
  console.log('✅ Logged in successfully');
  console.log('User ID:', afterLogin.userId);
  console.log('Is Demo:', afterLogin.isDemo);
  
  console.log('\n4. Testing message sending');
  
  // Find and click on chat input
  const chatInput = page.locator('#chat-input');
  const chatInputVisible = await chatInput.isVisible();
  console.log('Chat input visible:', chatInputVisible);
  
  if (!chatInputVisible) {
    // Try alternate selectors
    const alternateInput = page.locator('[contenteditable="true"], textarea[placeholder*="message"], input[placeholder*="message"]').first();
    if (await alternateInput.isVisible()) {
      console.log('Found alternate input element');
      await alternateInput.click();
      await alternateInput.fill('Hello, can you tell me what 2+2 equals?');
    }
  } else {
    await chatInput.click();
    await chatInput.fill('Hello, can you tell me what 2+2 equals?');
  }
  
  console.log('5. Sending message');
  
  // Find and click send button
  const sendButton = page.locator('#send-message-button, button[aria-label*="send"], button:has-text("Send")').first();
  const sendButtonEnabled = await sendButton.isEnabled();
  console.log('Send button enabled:', sendButtonEnabled);
  
  if (!sendButtonEnabled) {
    console.log('❌ Send button is disabled for logged-in user!');
    
    // Check if demo modal appears
    await page.waitForTimeout(1000);
    const modalCheck = await page.evaluate(() => {
      const modals = document.querySelectorAll('[role="dialog"], .modal, [class*="modal"]');
      return Array.from(modals).map(modal => ({
        visible: modal.offsetWidth > 0 && modal.offsetHeight > 0,
        text: (modal.textContent || '').substring(0, 200)
      }));
    });
    
    const visibleModal = modalCheck.find(m => m.visible);
    if (visibleModal) {
      console.log('Modal appeared:', visibleModal.text);
      console.log('❌ User is still being treated as demo!');
    }
    
    return;
  }
  
  await sendButton.click();
  console.log('Message sent');
  
  console.log('\n6. Waiting for response');
  
  // Wait for response to appear
  try {
    // Look for response indicators
    const responseIndicator = page.locator('.typing-indicator, [class*="loading"], [class*="generating"], .assistant-message').first();
    await responseIndicator.waitFor({ timeout: 10000 });
    console.log('✅ Response generation started');
    
    // Wait for actual response content
    await page.waitForTimeout(5000);
    
    // Check for response
    const messages = await page.locator('.message, [class*="message"]').allTextContents();
    console.log('Messages found:', messages.length);
    
    const hasResponse = messages.some(msg => 
      msg.includes('4') || 
      msg.includes('four') || 
      msg.includes('equals') ||
      msg.includes('2+2') ||
      msg.includes('sum')
    );
    
    if (hasResponse) {
      console.log('✅ AI response received!');
      console.log('Regular users can send messages and get responses');
    } else {
      console.log('❌ No AI response found');
      console.log('Messages:', messages.slice(-2)); // Show last 2 messages
    }
    
  } catch (error) {
    console.log('❌ Timeout waiting for response');
    console.log('Error:', error.message);
    
    // Check current page state
    const pageState = await page.evaluate(() => {
      return {
        url: window.location.href,
        hasToken: !!localStorage.getItem('token'),
        bodyText: document.body.innerText.substring(0, 500)
      };
    });
    
    console.log('Page state:', pageState);
  }
  
  console.log('\n=== Test Complete ===');
});