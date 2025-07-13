import { test, expect } from '@playwright/test';

test.describe('Chat Interface Test', () => {
  test('Verify chat interface loads and check send button', async ({ page }) => {
    // Increase timeout for this test
    test.setTimeout(60000);
    
    await page.goto('http://95.217.152.30:3000');
    
    // Wait for the page to fully load
    await page.waitForLoadState('domcontentloaded');
    await page.waitForLoadState('networkidle');
    
    // Additional wait for SPA to initialize
    await page.waitForTimeout(5000);
    
    console.log('Current URL:', page.url());
    
    // Check if we have a chat list or need to create a new chat
    const chatLinks = await page.locator('a[href^="/c/"]').count();
    console.log('Number of existing chats found:', chatLinks);
    
    if (chatLinks > 0) {
      // Click on the first chat
      console.log('Clicking on existing chat...');
      await page.locator('a[href^="/c/"]').first().click();
      await page.waitForLoadState('networkidle');
      await page.waitForTimeout(2000);
    } else {
      // Try to create a new chat
      console.log('No existing chats, looking for new chat button...');
      
      // Try multiple selectors for new chat button
      const newChatSelectors = [
        'button:has-text("New Chat")',
        'button[id*="new-chat"]',
        '#sidebar-new-chat-button',
        'button[aria-label*="New"]',
        'a[href="/"]',
        'button svg' // Sometimes it's just an icon
      ];
      
      for (const selector of newChatSelectors) {
        const button = page.locator(selector).first();
        if (await button.isVisible()) {
          console.log(`Found new chat button with selector: ${selector}`);
          await button.click();
          await page.waitForTimeout(2000);
          break;
        }
      }
    }
    
    // Now thoroughly check for the chat interface
    console.log('\nChecking for chat interface elements...');
    
    // Check for any textarea or input
    const allTextareas = await page.locator('textarea').count();
    const allInputs = await page.locator('input[type="text"]').count();
    console.log(`Found ${allTextareas} textareas and ${allInputs} text inputs on page`);
    
    // List all textareas with their properties
    for (let i = 0; i < allTextareas; i++) {
      const textarea = page.locator('textarea').nth(i);
      const placeholder = await textarea.getAttribute('placeholder');
      const id = await textarea.getAttribute('id');
      const isVisible = await textarea.isVisible();
      const isEnabled = await textarea.isEnabled();
      
      console.log(`Textarea ${i + 1}:`);
      console.log(`  ID: ${id}`);
      console.log(`  Placeholder: ${placeholder}`);
      console.log(`  Visible: ${isVisible}`);
      console.log(`  Enabled: ${isEnabled}`);
      
      if (placeholder?.toLowerCase().includes('sign in')) {
        console.log('  ⚠️  WARNING: This placeholder indicates user is not authenticated!');
      }
    }
    
    // Check for send button
    console.log('\nChecking for send button...');
    const allButtons = await page.locator('button').count();
    console.log(`Total buttons on page: ${allButtons}`);
    
    // Find potential send buttons
    const sendButtonSelectors = [
      'button#send-message-button',
      'button[aria-label*="send" i]',
      'button:has(svg[class*="send"])',
      'button[type="submit"]'
    ];
    
    for (const selector of sendButtonSelectors) {
      const button = page.locator(selector).first();
      if (await button.isVisible()) {
        const isDisabled = await button.isDisabled();
        const text = await button.textContent();
        console.log(`Found potential send button:`);
        console.log(`  Selector: ${selector}`);
        console.log(`  Text: ${text}`);
        console.log(`  Disabled: ${isDisabled}`);
        
        if (isDisabled) {
          console.log('  ❌ Button is DISABLED!');
          
          // Try to understand why it's disabled
          const className = await button.getAttribute('class');
          const disabled = await button.getAttribute('disabled');
          console.log(`  Class attribute: ${className}`);
          console.log(`  Disabled attribute: ${disabled}`);
        }
      }
    }
    
    // Final diagnostic: Check page content
    console.log('\nPage diagnostic:');
    const bodyText = await page.locator('body').textContent();
    
    if (bodyText?.includes('Sign in to start chatting')) {
      console.log('❌ CRITICAL: Page shows "Sign in to start chatting" - user authentication is broken!');
    }
    
    if (bodyText?.includes('New Chat') && !bodyText?.includes('Send a message')) {
      console.log('⚠️  Page might be showing empty state without chat interface');
    }
    
    // Take a final screenshot
    await page.screenshot({ path: 'test-results/chat-interface-final.png', fullPage: true });
    
    // One more check - inspect the DOM for the user store state
    const storeCheck = await page.evaluate(() => {
      const checkElement = document.querySelector('#send-message-button, button[disabled], textarea[placeholder*="Sign in"]');
      return {
        foundDisabledElement: !!checkElement,
        elementType: checkElement?.tagName,
        elementText: checkElement?.textContent || checkElement?.getAttribute('placeholder')
      };
    });
    
    console.log('\nDOM element check:', storeCheck);
  });
});