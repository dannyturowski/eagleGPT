import { test, expect } from '@playwright/test';

test.describe('Chat Submission', () => {
  test('logged-in admin user can send messages', async ({ page }) => {
    // Login as admin
    await page.goto('http://localhost:5173/auth');
    await page.fill('input[name="email"]', 'admin@example.com');
    await page.fill('input[name="password"]', 'password');
    await page.click('button[type="submit"]');
    
    // Wait for redirect to main chat
    await page.waitForURL('http://localhost:5173/');
    
    // Type a test message
    const testMessage = 'Test message from admin user';
    await page.fill('textarea#chat-input', testMessage);
    
    // Check console for errors
    page.on('console', msg => {
      if (msg.type() === 'error') {
        console.error('Browser console error:', msg.text());
      }
    });
    
    // Submit the message
    await page.press('textarea#chat-input', 'Enter');
    
    // Wait a moment for any errors to appear
    await page.waitForTimeout(1000);
    
    // Check if message appears in chat
    await expect(page.locator('.user-message').last()).toContainText(testMessage);
  });
  
  test('logged-in regular user can send messages', async ({ page }) => {
    // Login as regular user
    await page.goto('http://localhost:5173/auth');
    await page.fill('input[name="email"]', 'user@example.com');
    await page.fill('input[name="password"]', 'password');
    await page.click('button[type="submit"]');
    
    // Wait for redirect to main chat
    await page.waitForURL('http://localhost:5173/');
    
    // Type a test message
    const testMessage = 'Test message from regular user';
    await page.fill('textarea#chat-input', testMessage);
    
    // Submit the message
    await page.press('textarea#chat-input', 'Enter');
    
    // Wait a moment
    await page.waitForTimeout(1000);
    
    // Check if message appears in chat
    await expect(page.locator('.user-message').last()).toContainText(testMessage);
  });
  
  test('demo user cannot send messages and sees modal', async ({ page }) => {
    // Access as demo user
    await page.goto('http://localhost:5173/');
    await page.click('text=Try Demo');
    
    // Wait for chat interface
    await page.waitForSelector('textarea#chat-input');
    
    // Type a test message
    await page.fill('textarea#chat-input', 'Test message from demo user');
    
    // Try to submit
    await page.press('textarea#chat-input', 'Enter');
    
    // Modal should appear
    await expect(page.locator('.demo-restriction-modal')).toBeVisible();
    
    // Message should not appear in chat
    await expect(page.locator('.user-message')).toHaveCount(0);
  });
});