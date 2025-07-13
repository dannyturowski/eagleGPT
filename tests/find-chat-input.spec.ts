import { test, expect } from '@playwright/test';

test('Find the missing chat input', async ({ page }) => {
  await page.goto('http://95.217.152.30:3000');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(5000);
  
  // Check page source for MessageInput component
  const pageContent = await page.content();
  
  console.log('=== Component Search ===');
  console.log('Contains "MessageInput":', pageContent.includes('MessageInput'));
  console.log('Contains "chat-input":', pageContent.includes('chat-input'));
  console.log('Contains "send-message":', pageContent.includes('send-message'));
  
  // Check for elements that might be hidden
  const hiddenElements = await page.evaluate(() => {
    const elements = document.querySelectorAll('textarea, input[type="text"], div[contenteditable="true"]');
    const results = [];
    
    elements.forEach((el, index) => {
      const rect = el.getBoundingClientRect();
      const computed = window.getComputedStyle(el);
      
      results.push({
        index,
        tagName: el.tagName,
        id: el.id || 'none',
        className: el.className || 'none',
        visible: rect.width > 0 && rect.height > 0,
        display: computed.display,
        visibility: computed.visibility,
        opacity: computed.opacity,
        position: computed.position,
        top: rect.top,
        left: rect.left,
        width: rect.width,
        height: rect.height
      });
    });
    
    return results;
  });
  
  console.log('\n=== Hidden Elements Check ===');
  console.log(JSON.stringify(hiddenElements, null, 2));
  
  // Check for specific error messages or loading states
  const errorCheck = await page.evaluate(() => {
    const bodyText = document.body.textContent || '';
    return {
      hasError: bodyText.includes('Error') || bodyText.includes('error'),
      hasLoading: bodyText.includes('Loading') || bodyText.includes('loading'),
      hasDemo: bodyText.includes('demo') || bodyText.includes('Demo'),
      hasBrowse: bodyText.includes('Browse freely')
    };
  });
  
  console.log('\n=== Error/State Check ===');
  console.log(JSON.stringify(errorCheck, null, 2));
  
  // Try clicking on a suggested prompt to see if that reveals the input
  const firstPrompt = page.locator('text="Which VPN is most patriotic?"');
  if (await firstPrompt.isVisible()) {
    console.log('\n=== Clicking on suggested prompt ===');
    await firstPrompt.click();
    await page.waitForTimeout(3000);
    
    // Check again for textarea
    const textareaAfterClick = await page.locator('textarea').count();
    console.log('Textarea count after clicking prompt:', textareaAfterClick);
    
    // Take another screenshot
    await page.screenshot({ path: 'test-results/after-prompt-click.png', fullPage: true });
  }
  
  // Final check: Look for any element that might be blocking the input
  const blockingElements = await page.evaluate(() => {
    // Find elements that might be overlaying the bottom of the page
    const elements = document.querySelectorAll('div, section, footer');
    const bottomElements = [];
    
    elements.forEach(el => {
      const rect = el.getBoundingClientRect();
      const computed = window.getComputedStyle(el);
      
      // Check if element is at the bottom of viewport
      if (rect.bottom >= window.innerHeight - 200 && rect.height > 0) {
        bottomElements.push({
          tagName: el.tagName,
          id: el.id || 'none',
          className: el.className || 'none',
          text: el.textContent?.substring(0, 50) || 'none',
          position: computed.position,
          bottom: rect.bottom,
          height: rect.height,
          zIndex: computed.zIndex
        });
      }
    });
    
    return bottomElements;
  });
  
  console.log('\n=== Bottom Elements (might be blocking input) ===');
  console.log(JSON.stringify(blockingElements, null, 2));
});