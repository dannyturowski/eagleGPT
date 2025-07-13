import { test, expect } from '@playwright/test';

test('Test actual message sending', async ({ page }) => {
  await page.goto('http://95.217.152.30:3000');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(3000);
  
  console.log('1. Current URL:', page.url());
  
  // Find and click the chat input
  const chatInput = page.locator('#chat-input');
  await chatInput.click();
  
  // Type a message
  await chatInput.fill('Test message from Playwright');
  
  console.log('2. Message typed in input');
  
  // Find the send button
  const sendButton = page.locator('#send-message-button');
  
  // Check button state
  const isDisabled = await sendButton.isDisabled();
  const isVisible = await sendButton.isVisible();
  
  console.log('3. Send button state:');
  console.log('   - Visible:', isVisible);
  console.log('   - Disabled:', isDisabled);
  
  if (isVisible && !isDisabled) {
    console.log('4. Clicking send button...');
    
    // Listen for any modal that might appear
    page.on('dialog', dialog => {
      console.log('Dialog appeared:', dialog.message());
      dialog.dismiss();
    });
    
    // Click the send button
    await sendButton.click();
    
    // Wait to see what happens
    await page.waitForTimeout(3000);
    
    // Check for demo restriction modal
    const modalTexts = [
      'Demo users cannot',
      'Sign up to start',
      'Sign up for full access',
      'Create Account'
    ];
    
    let foundModal = false;
    for (const text of modalTexts) {
      const modal = page.locator(`text="${text}"`);
      if (await modal.isVisible()) {
        console.log(`5. ✅ Demo restriction modal appeared with text: "${text}"`);
        foundModal = true;
        break;
      }
    }
    
    if (!foundModal) {
      // Check if message was sent
      const messages = await page.locator('.message-content, [class*="message"]').count();
      console.log(`5. No modal found. Message count on page: ${messages}`);
      
      // Check if the input was cleared (indicating message was sent)
      const inputValue = await chatInput.textContent();
      console.log(`   Input value after send: "${inputValue}"`);
      
      if (inputValue === '' || inputValue === null) {
        console.log('   ✅ Input was cleared - message might have been sent');
      } else {
        console.log('   ❌ Input still contains text - message was not sent');
      }
    }
    
    // Take a screenshot of the result
    await page.screenshot({ path: 'test-results/after-send-attempt.png', fullPage: true });
    
    // Final check: See if we're still a demo user
    const tokenCheck = await page.evaluate(() => {
      const token = localStorage.getItem('token');
      if (token) {
        try {
          const parts = token.split('.');
          const payload = JSON.parse(atob(parts[1]));
          return {
            userId: payload.id,
            isDemo: payload.id === 'demo_eaglegpt_shared'
          };
        } catch (e) {
          return { error: e.message };
        }
      }
      return { hasToken: false };
    });
    
    console.log('\n6. Token check:', tokenCheck);
    
    if (tokenCheck.isDemo) {
      console.log('   User is confirmed as demo user');
      if (!foundModal) {
        console.log('   ⚠️  WARNING: Demo user was able to send without restriction!');
      }
    }
  } else {
    console.log('❌ Send button is not clickable!');
  }
});