import { test, expect } from '@playwright/test';

test('Test authentication flow issue', async ({ page, context }) => {
  console.log('1. Starting with clean state');
  
  // Clear all cookies and localStorage
  await context.clearCookies();
  await page.goto('http://95.217.152.30:3000');
  await page.evaluate(() => {
    localStorage.clear();
    sessionStorage.clear();
  });
  
  console.log('2. Navigating to auth page directly');
  await page.goto('http://95.217.152.30:3000/auth');
  await page.waitForLoadState('networkidle');
  
  // Check if we stayed on auth page
  console.log('Current URL:', page.url());
  
  // Check localStorage
  const authPageState = await page.evaluate(() => {
    return {
      hasToken: !!localStorage.getItem('token'),
      pathname: window.location.pathname
    };
  });
  
  console.log('Auth page state:', authPageState);
  
  console.log('\n3. Now navigating to main page');
  await page.goto('http://95.217.152.30:3000');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);
  
  // Check what happened
  const mainPageState = await page.evaluate(() => {
    const token = localStorage.getItem('token');
    let tokenInfo = null;
    
    if (token) {
      try {
        const parts = token.split('.');
        const payload = JSON.parse(atob(parts[1]));
        tokenInfo = {
          id: payload.id,
          exp: payload.exp,
          isDemo: payload.id === 'demo_eaglegpt_shared'
        };
      } catch (e) {}
    }
    
    return {
      url: window.location.href,
      hasToken: !!token,
      tokenInfo: tokenInfo
    };
  });
  
  console.log('Main page state:', JSON.stringify(mainPageState, null, 2));
  
  console.log('\n4. Testing the real issue:');
  console.log('The root layout is automatically creating a demo token for anyone without a token.');
  console.log('This means:');
  console.log('- Logged-in users whose token expired get a demo token instead of being asked to log in again');
  console.log('- New users get a demo token immediately instead of seeing the login page');
  console.log('- The demo token is created BEFORE checking if the user wants to log in');
  
  // Simulate what happens when a real user's token expires
  console.log('\n5. Simulating expired token scenario');
  
  // Clear the token to simulate expiration
  await page.evaluate(() => {
    localStorage.removeItem('token');
  });
  
  // Refresh the page
  await page.reload();
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(2000);
  
  // Check what happened
  const afterReloadState = await page.evaluate(() => {
    const token = localStorage.getItem('token');
    let tokenInfo = null;
    
    if (token) {
      try {
        const parts = token.split('.');
        const payload = JSON.parse(atob(parts[1]));
        tokenInfo = {
          id: payload.id,
          isDemo: payload.id === 'demo_eaglegpt_shared'
        };
      } catch (e) {}
    }
    
    return {
      hasToken: !!token,
      tokenInfo: tokenInfo,
      url: window.location.href
    };
  });
  
  console.log('After reload (simulating expired token):', JSON.stringify(afterReloadState, null, 2));
  
  if (afterReloadState.tokenInfo?.isDemo) {
    console.log('\n❌ CONFIRMED: User got a demo token instead of being redirected to login!');
    console.log('This is why ALL users are being treated as demo users.');
  }
});