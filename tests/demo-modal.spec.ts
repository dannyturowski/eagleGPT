import { test, expect } from '@playwright/test';

test.describe('Demo User Restrictions', () => {
  test('should show demo restriction modal when trying to submit chat', async ({ page }) => {
    // Go to the eagleGPT homepage
    await page.goto('http://localhost:5174');
    
    // Wait for the page to load and auto-login as demo user
    await page.waitForTimeout(3000);
    
    // Check if we're on the chat page (demo auto-login should have worked)
    await expect(page).toHaveURL(/\/c\//);
    
    // Find the chat input
    const chatInput = page.locator('#chat-input');
    await expect(chatInput).toBeVisible();
    
    // Type a message
    await chatInput.fill('Test message from demo user');
    
    // Submit the form (press Enter)
    await chatInput.press('Enter');
    
    // Wait for the modal to appear
    const modal = page.locator('text=Join the Patriot Community!');
    await expect(modal).toBeVisible({ timeout: 5000 });
    
    // Check modal content
    await expect(page.locator('text=Demo mode is view-only')).toBeVisible();
    await expect(page.locator('text=create a free account')).toBeVisible();
    
    // Check buttons are present
    const signUpButton = page.locator('button:has-text("Sign Up Free")');
    const continueButton = page.locator('button:has-text("Continue Browsing")');
    
    await expect(signUpButton).toBeVisible();
    await expect(continueButton).toBeVisible();
    
    // Test "Continue Browsing" button
    await continueButton.click();
    
    // Modal should be hidden
    await expect(modal).not.toBeVisible();
    
    // Test "Sign Up Free" button
    await chatInput.press('Enter');
    await expect(modal).toBeVisible({ timeout: 5000 });
    await signUpButton.click();
    
    // Should redirect to auth page
    await expect(page).toHaveURL(/\/auth/);
  });
  
  test('should show demo user profile in sidebar', async ({ page }) => {
    await page.goto('http://localhost:5173');
    await page.waitForTimeout(3000);
    
    // Check if demo user info is displayed
    const demoUserName = page.locator('text=Demo User');
    await expect(demoUserName).toBeVisible();
  });
});