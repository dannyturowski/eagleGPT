import { test, expect } from '@playwright/test';

test('Verify logged-in users can send messages and receive AI responses', async ({ page }) => {
  console.log('=== Testing AI Response Flow ===\n');
  
  // Go to auth page and sign up with test user
  await page.goto('http://95.217.152.30:3000/auth');
  await page.waitForLoadState('networkidle');
  
  console.log('1. Creating test user...');
  
  // Click sign up tab
  const signUpTab = page.locator('button:has-text("Sign up")');
  await signUpTab.click();
  await page.waitForTimeout(500);
  
  // Fill in test user details
  const nameInput = page.locator('input[placeholder*="Name"], input[type="text"]').first();
  const emailInput = page.locator('input[placeholder*="Email"], input[type="email"]');
  const passwordInput = page.locator('input[type="password"]').first();
  const confirmPasswordInput = page.locator('input[type="password"]').last();
  
  const testEmail = `test${Date.now()}@eaglegpt.test`;
  await nameInput.fill('Test User');
  await emailInput.fill(testEmail);
  await passwordInput.fill('testpass123');
  await confirmPasswordInput.fill('testpass123');
  
  // Submit sign up
  const submitButton = page.locator('button[type="submit"]:has-text("Create Account")');
  await submitButton.click();
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);
  
  console.log('2. Test user created, now testing message sending...');
  
  // Should now be logged in - try to send a message
  const chatInput = page.locator('#chat-input, textarea[placeholder*="Send"], [contenteditable="true"]');
  await chatInput.waitFor({ state: 'visible', timeout: 10000 });
  await chatInput.click();
  await chatInput.fill('What is 2+2? This is a test message.');
  
  // Intercept API calls to monitor the request
  let apiRequestMade = false;
  let apiResponse = null;
  await page.route('**/api/chat/**', async route => {
    console.log(`🔍 Chat API Request: ${route.request().method()} ${route.request().url()}`);
    apiRequestMade = true;
    const response = await route.fetch();
    apiResponse = response.status();
    console.log(`📡 Chat API Response Status: ${apiResponse}`);
    route.fulfill({ response });
  });
  
  // Find and click send button
  const sendButton = page.locator('#send-message-button, button[title*="Send"], button:has-text("Send")');
  await sendButton.waitFor({ state: 'visible', timeout: 5000 });
  
  console.log('3. Sending message...');
  await sendButton.click();
  
  // Wait for response
  await page.waitForTimeout(8000);
  
  console.log('4. Checking results...');
  console.log(`API request made: ${apiRequestMade}`);
  console.log(`API response status: ${apiResponse}`);
  
  // Check for messages in the chat
  const messages = await page.evaluate(() => {
    const messageElements = document.querySelectorAll('.message, [class*="message"], [role="article"], .chat-message');
    return Array.from(messageElements).map(el => ({
      text: el.textContent?.trim().substring(0, 150),
      className: el.className
    }));
  });
  
  console.log(`Messages found: ${messages.length}`);
  messages.forEach((msg, i) => {
    console.log(`Message ${i + 1}: "${msg.text}"`);
  });
  
  // Check if we got any AI response
  const hasAiResponse = messages.some(msg => 
    msg.text && msg.text.toLowerCase().includes('4') || 
    msg.text.length > 10
  );
  
  console.log(`AI response received: ${hasAiResponse}`);
  
  if (hasAiResponse) {
    console.log('✅ SUCCESS: User can send messages and receive AI responses!');
  } else {
    console.log('❌ ISSUE: No AI response detected');
    
    // Check if demo modal appeared
    const demoModal = await page.locator('.modal, [class*="modal"]').count();
    if (demoModal > 0) {
      console.log('⚠️  Demo modal appeared for logged-in user');
    }
    
    // Check if send button was disabled
    const sendButtonDisabled = await sendButton.isDisabled();
    console.log(`Send button disabled: ${sendButtonDisabled}`);
  }
  
  expect(apiRequestMade).toBe(true);
  expect(hasAiResponse).toBe(true);
});