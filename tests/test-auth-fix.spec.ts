import { test, expect } from '@playwright/test';

test('Test authentication flow fix', async ({ page, context }) => {
  console.log('=== Testing Authentication Flow Fix ===\n');
  
  // Clear all cookies and localStorage
  await context.clearCookies();
  await page.goto('http://localhost:5174');
  await page.evaluate(() => {
    localStorage.clear();
    sessionStorage.clear();
  });
  
  console.log('1. Testing that anonymous users are redirected to auth page');
  await page.goto('http://localhost:5174');
  await page.waitForLoadState('networkidle');
  
  // Should be redirected to auth page
  expect(page.url()).toContain('/auth');
  console.log('✅ Anonymous users are redirected to /auth');
  
  console.log('\n2. Testing that no automatic demo token is created');
  const tokenCheck = await page.evaluate(() => {
    return {
      hasToken: !!localStorage.getItem('token'),
      token: localStorage.getItem('token')
    };
  });
  
  expect(tokenCheck.hasToken).toBe(false);
  console.log('✅ No automatic demo token created');
  
  console.log('\n3. Testing explicit demo mode button');
  // Look for the demo button
  const demoButton = page.locator('button:has-text("Browse as Demo")');
  expect(await demoButton.isVisible()).toBe(true);
  console.log('✅ Demo button is visible');
  
  // Click the demo button
  await demoButton.click();
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);
  
  // Check if demo token was created
  const afterDemoClick = await page.evaluate(() => {
    const token = localStorage.getItem('token');
    if (token) {
      try {
        const parts = token.split('.');
        const payload = JSON.parse(atob(parts[1]));
        return {
          hasToken: true,
          userId: payload.id,
          isDemo: payload.id === 'demo_eaglegpt_shared'
        };
      } catch (e) {}
    }
    return { hasToken: false };
  });
  
  expect(afterDemoClick.hasToken).toBe(true);
  expect(afterDemoClick.isDemo).toBe(true);
  console.log('✅ Demo token created after explicit button click');
  console.log('   User ID:', afterDemoClick.userId);
  
  console.log('\n4. Testing that demo users see restriction modal');
  // Should be redirected to main chat
  expect(page.url()).not.toContain('/auth');
  
  // Try to send a message
  const chatInput = page.locator('#chat-input');
  if (await chatInput.isVisible()) {
    await chatInput.click();
    await chatInput.fill('Test message');
    
    const sendButton = page.locator('#send-message-button');
    await sendButton.click();
    await page.waitForTimeout(1000);
    
    // Check for demo restriction modal
    const modal = page.locator('[role="dialog"], .modal').first();
    const modalVisible = await modal.isVisible();
    const modalText = modalVisible ? await modal.textContent() : '';
    
    expect(modalVisible).toBe(true);
    expect(modalText).toContain('Sign Up Free');
    console.log('✅ Demo restriction modal appears for demo users');
  }
  
  console.log('\n5. Testing regular login flow');
  // Clear session again
  await page.evaluate(() => localStorage.clear());
  await page.goto('http://localhost:5174/auth');
  
  // Check that sign in form is visible
  const emailInput = page.locator('input[type="email"]');
  const passwordInput = page.locator('input[type="password"]');
  const signInButton = page.locator('button:has-text("Sign in")').first();
  
  expect(await emailInput.isVisible()).toBe(true);
  expect(await passwordInput.isVisible()).toBe(true);
  expect(await signInButton.isVisible()).toBe(true);
  console.log('✅ Login form is visible for regular users');
  
  console.log('\n=== All Tests Passed! ===');
  console.log('The authentication flow has been fixed:');
  console.log('- No automatic demo tokens');
  console.log('- Explicit demo button required');
  console.log('- Regular users can log in normally');
});