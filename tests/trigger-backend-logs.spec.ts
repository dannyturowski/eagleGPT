import { test, expect } from '@playwright/test';

test('Trigger backend activity to check logs', async ({ page }) => {
  console.log('=== Triggering Backend Activity ===\n');
  
  await page.goto('http://95.217.152.30:3000/auth');
  await page.waitForLoadState('networkidle');
  
  console.log('1. Testing with demo user to trigger backend');
  const demoButton = page.locator('button:has-text("Browse as Demo")');
  await demoButton.click();
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);
  
  console.log('2. Attempting to send message to trigger backend processing');
  const chatInput = page.locator('#chat-input');
  await chatInput.click();
  await chatInput.fill('What is 2+2? Please respond.');
  
  // Intercept the actual submission
  let requestMade = false;
  await page.route('**/api/**', route => {
    console.log(`🔍 API Request: ${route.request().method()} ${route.request().url()}`);
    requestMade = true;
    route.continue();
  });
  
  const sendButton = page.locator('#send-message-button');
  await sendButton.click();
  
  await page.waitForTimeout(5000);
  
  console.log('Request intercepted:', requestMade);
  
  // Check if anything appeared in the chat
  const messages = await page.evaluate(() => {
    const messageElements = document.querySelectorAll('.message, [class*="message"], [role="article"]');
    return Array.from(messageElements).map(el => ({
      text: el.textContent?.trim().substring(0, 100),
      className: el.className
    }));
  });
  
  console.log('Messages found:', messages.length);
  if (messages.length > 0) {
    console.log('Last message:', messages[messages.length - 1]);
  }
  
  console.log('\n3. Check backend logs now for any processing attempts or errors');
});