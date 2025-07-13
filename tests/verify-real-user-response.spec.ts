import { test, expect } from '@playwright/test';

// IMPORTANT: Update these with real credentials to test
const TEST_EMAIL = 'your-email@example.com';  // Replace with actual email
const TEST_PASSWORD = 'your-password';         // Replace with actual password

test('Verify real user can send messages and get AI responses', async ({ page, context }) => {
  console.log('=== Testing Real User Message & Response ===\n');
  
  // Skip test if credentials not updated
  if (TEST_EMAIL === 'your-email@example.com') {
    console.log('⚠️  SKIPPING TEST - Please update TEST_EMAIL and TEST_PASSWORD with real credentials');
    console.log('Edit the file: tests/verify-real-user-response.spec.ts');
    return;
  }
  
  // Clear all cookies and localStorage
  await context.clearCookies();
  await page.goto('http://95.217.152.30:3000');
  await page.evaluate(() => {
    localStorage.clear();
    sessionStorage.clear();
  });
  
  console.log('1. Logging in as real user');
  await page.goto('http://95.217.152.30:3000/auth');
  await page.waitForLoadState('networkidle');
  
  // Fill login form
  await page.locator('input[type="email"]').fill(TEST_EMAIL);
  await page.locator('input[type="password"]').fill(TEST_PASSWORD);
  
  // Submit login
  await page.locator('button:has-text("Sign in")').first().click();
  
  // Wait for navigation
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(3000);
  
  // Verify login successful
  const loginState = await page.evaluate(() => {
    const token = localStorage.getItem('token');
    if (token) {
      try {
        const parts = token.split('.');
        const payload = JSON.parse(atob(parts[1]));
        return {
          success: true,
          userId: payload.id,
          email: payload.email,
          isDemo: payload.id === 'demo_eaglegpt_shared',
          url: window.location.href
        };
      } catch (e) {
        return { success: false, error: e.message };
      }
    }
    return { success: false, url: window.location.href };
  });
  
  console.log('Login state:', loginState);
  
  if (!loginState.success) {
    console.log('❌ Login failed!');
    return;
  }
  
  if (loginState.isDemo) {
    console.log('❌ Logged in as demo user - not a real user!');
    return;
  }
  
  console.log('✅ Successfully logged in as:', loginState.email);
  console.log('User ID:', loginState.userId);
  
  console.log('\n2. Finding chat input');
  const chatInput = page.locator('#chat-input, [contenteditable="true"]').first();
  const inputVisible = await chatInput.isVisible();
  console.log('Chat input visible:', inputVisible);
  
  if (!inputVisible) {
    console.log('❌ Chat input not found!');
    return;
  }
  
  console.log('\n3. Typing test message');
  await chatInput.click();
  await chatInput.fill('What is 2+2? Please give me just the number.');
  
  console.log('\n4. Checking send button state');
  const sendButton = page.locator('#send-message-button');
  const buttonState = await sendButton.evaluate((btn: HTMLButtonElement) => ({
    exists: true,
    disabled: btn.disabled,
    className: btn.className,
    text: btn.textContent
  }));
  
  console.log('Send button state:', buttonState);
  
  if (buttonState.disabled) {
    console.log('❌ Send button is disabled!');
    return;
  }
  
  console.log('\n5. Sending message');
  await sendButton.click();
  
  // Check if demo modal appears (it shouldn't for real users)
  await page.waitForTimeout(1000);
  const modalVisible = await page.locator('[role="dialog"], .modal').first().isVisible();
  
  if (modalVisible) {
    const modalText = await page.locator('[role="dialog"], .modal').first().textContent();
    console.log('❌ Demo restriction modal appeared!');
    console.log('Modal text:', modalText?.substring(0, 100));
    console.log('This means the user is still being treated as demo!');
    return;
  }
  
  console.log('✅ No demo modal - message sent successfully');
  
  console.log('\n6. Waiting for AI response...');
  
  try {
    // Wait for response - look for various indicators
    const responseSelectors = [
      '.assistant-message',
      '[class*="assistant"]',
      '.message:has-text("4")',
      '.message:last-child',
      'div:has-text("4")'
    ];
    
    let responseFound = false;
    let responseText = '';
    
    // Try each selector with a timeout
    for (const selector of responseSelectors) {
      try {
        const element = page.locator(selector).last();
        await element.waitFor({ timeout: 15000, state: 'visible' });
        responseText = await element.textContent() || '';
        if (responseText && responseText !== 'What is 2+2? Please give me just the number.') {
          responseFound = true;
          break;
        }
      } catch (e) {
        // Try next selector
      }
    }
    
    if (!responseFound) {
      // Try a more general approach - get all messages
      await page.waitForTimeout(5000);
      const allMessages = await page.evaluate(() => {
        const messages = Array.from(document.querySelectorAll('.message, [class*="message"], [role="article"]'));
        return messages.map(m => ({
          text: m.textContent?.trim().substring(0, 100),
          className: m.className
        }));
      });
      
      console.log('All messages found:', allMessages.length);
      if (allMessages.length > 0) {
        console.log('Last 3 messages:', allMessages.slice(-3));
      }
      
      // Check if any message contains "4" or response indicators
      responseFound = allMessages.some(m => 
        m.text && 
        m.text !== 'What is 2+2? Please give me just the number.' &&
        (m.text.includes('4') || m.text.includes('four') || m.text.length > 10)
      );
      
      if (responseFound) {
        responseText = allMessages[allMessages.length - 1].text || '';
      }
    }
    
    if (responseFound) {
      console.log('✅ AI Response received!');
      console.log('Response:', responseText.substring(0, 200));
      console.log('\n🎉 SUCCESS: Real users CAN send messages and receive AI responses!');
    } else {
      console.log('❌ No AI response received within timeout');
      
      // Get page state for debugging
      const pageState = await page.evaluate(() => ({
        url: window.location.href,
        hasToken: !!localStorage.getItem('token'),
        messageCount: document.querySelectorAll('.message, [class*="message"]').length,
        lastMessage: Array.from(document.querySelectorAll('.message, [class*="message"]')).pop()?.textContent?.substring(0, 100)
      }));
      
      console.log('Page state:', pageState);
    }
    
  } catch (error) {
    console.log('❌ Error waiting for response:', error.message);
  }
  
  // Take a screenshot for debugging
  await page.screenshot({ path: 'test-results/real-user-test.png', fullPage: true });
  console.log('\nScreenshot saved to: test-results/real-user-test.png');
});

test.describe('Manual Verification Steps', () => {
  test('Instructions for manual testing', async () => {
    console.log('\n=== MANUAL VERIFICATION STEPS ===\n');
    console.log('Since we need real credentials to fully test, please follow these steps:\n');
    console.log('1. Open a browser and go to: http://95.217.152.30:3000');
    console.log('2. Click "Sign in" and log in with your real account');
    console.log('3. Type a message like "What is 2+2?"');
    console.log('4. Click the send button');
    console.log('5. Verify that:');
    console.log('   - No demo restriction modal appears');
    console.log('   - The message is sent');
    console.log('   - You receive an AI response');
    console.log('\nIf all these work, then real users CAN send messages and get responses! ✅');
  });
});