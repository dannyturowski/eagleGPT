import { test, expect } from '@playwright/test';

test('Check current state of EagleGPT', async ({ page }) => {
  await page.goto('http://95.217.152.30:3000');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(5000);
  
  // Take a screenshot
  await page.screenshot({ path: 'test-results/current-state.png', fullPage: true });
  
  // Get basic page info
  console.log('=== Page State ===');
  console.log('URL:', page.url());
  console.log('Title:', await page.title());
  
  // Check for specific text on page
  const pageText = await page.locator('body').textContent();
  
  console.log('\n=== Key Text Checks ===');
  console.log('Contains "Sign in":', pageText?.includes('Sign in'));
  console.log('Contains "New Chat":', pageText?.includes('New Chat'));
  console.log('Contains "Send":', pageText?.includes('Send'));
  console.log('Contains "Type a message":', pageText?.includes('Type a message'));
  
  // Check for auth elements
  const hasLoginForm = await page.locator('input[type="email"]').isVisible();
  const hasPasswordField = await page.locator('input[type="password"]').isVisible();
  
  console.log('\n=== Auth Elements ===');
  console.log('Has login form:', hasLoginForm);
  console.log('Has password field:', hasPasswordField);
  
  // Check for chat elements
  const textareaCount = await page.locator('textarea').count();
  const buttonCount = await page.locator('button').count();
  
  console.log('\n=== UI Elements ===');
  console.log('Textarea count:', textareaCount);
  console.log('Button count:', buttonCount);
  
  // If there's a textarea, check its properties
  if (textareaCount > 0) {
    const textarea = page.locator('textarea').first();
    console.log('\n=== First Textarea Properties ===');
    console.log('Placeholder:', await textarea.getAttribute('placeholder'));
    console.log('Visible:', await textarea.isVisible());
    console.log('Enabled:', await textarea.isEnabled());
  }
  
  // Check localStorage
  const localStorageData = await page.evaluate(() => {
    return {
      hasToken: !!localStorage.getItem('token'),
      tokenLength: localStorage.getItem('token')?.length || 0
    };
  });
  
  console.log('\n=== LocalStorage ===');
  console.log('Has token:', localStorageData.hasToken);
  console.log('Token length:', localStorageData.tokenLength);
});