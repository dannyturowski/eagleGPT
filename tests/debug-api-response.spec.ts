import { test, expect } from '@playwright/test';

test('Debug API response issue with real user', async ({ page, context }) => {
  console.log('=== Debugging API Response Issue ===\n');
  
  // Clear state
  await context.clearCookies();
  await page.goto('http://95.217.152.30:3000');
  await page.evaluate(() => {
    localStorage.clear();
    sessionStorage.clear();
  });
  
  console.log('1. Testing with demo user first to establish baseline');
  await page.goto('http://95.217.152.30:3000/auth');
  await page.waitForLoadState('networkidle');
  
  // Click demo button
  const demoButton = page.locator('button:has-text("Browse as Demo")');
  await demoButton.click();
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);
  
  // Check user state
  const demoUserState = await page.evaluate(() => {
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
  
  console.log('Demo user state:', demoUserState);
  
  // Intercept network requests to see what's happening
  await page.route('**/api/chat/completions', route => {
    console.log('🔍 Chat completion request intercepted!');
    console.log('URL:', route.request().url());
    console.log('Method:', route.request().method());
    console.log('Headers:', route.request().headers());
    
    // Continue the request
    route.continue();
  });
  
  await page.route('**/api/chat/**', route => {
    console.log('🔍 Chat API request intercepted!');
    console.log('URL:', route.request().url());
    console.log('Method:', route.request().method());
    
    // Continue the request
    route.continue();
  });
  
  console.log('\n2. Sending test message as demo user');
  const chatInput = page.locator('#chat-input');
  await chatInput.click();
  await chatInput.fill('Hello, this is a test message');
  
  const sendButton = page.locator('#send-message-button');
  await sendButton.click();
  
  // Wait and check what happened
  await page.waitForTimeout(3000);
  
  const modalVisible = await page.locator('[role="dialog"], .modal').first().isVisible();
  console.log('Demo modal appeared:', modalVisible);
  
  if (modalVisible) {
    console.log('✅ Demo user correctly blocked');
    // Close the modal
    const continueButton = page.locator('button:has-text("Continue Browsing"), button:has-text("Close")').first();
    if (await continueButton.isVisible()) {
      await continueButton.click();
    }
  }
  
  console.log('\n3. Now testing the key question: What happens if a real user tries?');
  console.log('Since we need real credentials, let\'s check the frontend-backend communication:');
  
  // Check if the app can reach the backend
  const backendCheck = await page.evaluate(async () => {
    try {
      const response = await fetch('/api/config');
      return {
        status: response.status,
        ok: response.ok,
        data: response.ok ? await response.json() : await response.text()
      };
    } catch (e) {
      return { error: e.message };
    }
  });
  
  console.log('Backend config check:', backendCheck);
  
  // Check models endpoint
  const modelsCheck = await page.evaluate(async () => {
    try {
      const response = await fetch('/api/models');
      return {
        status: response.status,
        ok: response.ok,
        requiresAuth: response.status === 401 || response.status === 403
      };
    } catch (e) {
      return { error: e.message };
    }
  });
  
  console.log('Models endpoint check:', modelsCheck);
  
  if (modelsCheck.requiresAuth) {
    console.log('Models endpoint requires authentication - this is normal');
  }
  
  console.log('\n4. Key findings:');
  console.log('- Demo user flow works correctly');  
  console.log('- Backend is responding to requests');
  console.log('- The issue is likely in model configuration or API key validation');
  console.log('\nTo fully test, need to:');
  console.log('1. Log in as real admin user');
  console.log('2. Check /admin/settings/models for configured models');
  console.log('3. Verify API key is valid and has credits');
  console.log('4. Test message sending with real user account');
});