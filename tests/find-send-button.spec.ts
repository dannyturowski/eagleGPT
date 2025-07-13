import { test, expect } from '@playwright/test';

test('Find the send button', async ({ page }) => {
  await page.goto('http://95.217.152.30:3000');
  await page.waitForLoadState('networkidle');
  await page.waitForTimeout(5000);
  
  // First, type something in the chat input to see if send button appears
  const chatInput = page.locator('#chat-input');
  if (await chatInput.isVisible()) {
    console.log('Found chat input, typing message...');
    await chatInput.click();
    await chatInput.fill('Test message');
    await page.waitForTimeout(1000);
  }
  
  // Search for all buttons
  const allButtons = await page.evaluate(() => {
    const buttons = document.querySelectorAll('button');
    const buttonInfo = [];
    
    buttons.forEach((btn, index) => {
      const rect = btn.getBoundingClientRect();
      const computed = window.getComputedStyle(btn);
      
      buttonInfo.push({
        index,
        id: btn.id || 'none',
        className: btn.className || 'none',
        text: btn.textContent?.trim() || 'none',
        ariaLabel: btn.getAttribute('aria-label') || 'none',
        type: btn.type,
        disabled: btn.disabled,
        visible: rect.width > 0 && rect.height > 0,
        display: computed.display,
        position: computed.position,
        bottom: rect.bottom,
        right: rect.right,
        hasIcon: btn.querySelector('svg') !== null
      });
    });
    
    return buttonInfo;
  });
  
  console.log(`\n=== Found ${allButtons.length} buttons ===`);
  
  // Filter for potential send buttons
  const potentialSendButtons = allButtons.filter(btn => 
    btn.id.includes('send') ||
    btn.className.includes('send') ||
    btn.text.toLowerCase().includes('send') ||
    btn.ariaLabel.toLowerCase().includes('send') ||
    (btn.hasIcon && btn.bottom > 400) // Icon buttons near bottom
  );
  
  console.log('\n=== Potential Send Buttons ===');
  console.log(JSON.stringify(potentialSendButtons, null, 2));
  
  // Look for buttons near the chat input
  const bottomButtons = allButtons.filter(btn => btn.bottom > 350 && btn.visible);
  console.log('\n=== Buttons near chat input (bottom > 350) ===');
  bottomButtons.forEach(btn => {
    console.log(`Button ${btn.index}: ${btn.text || btn.ariaLabel || 'icon-only'} (disabled: ${btn.disabled})`);
  });
  
  // Check for elements that might contain the send button
  const messageInputContainer = await page.evaluate(() => {
    const chatInput = document.getElementById('chat-input');
    if (!chatInput) return null;
    
    // Look for parent containers
    let parent = chatInput.parentElement;
    const containers = [];
    
    while (parent && containers.length < 5) {
      containers.push({
        tagName: parent.tagName,
        id: parent.id || 'none',
        className: parent.className || 'none',
        childCount: parent.children.length,
        hasButton: parent.querySelector('button') !== null,
        buttonCount: parent.querySelectorAll('button').length
      });
      parent = parent.parentElement;
    }
    
    return containers;
  });
  
  console.log('\n=== Chat Input Parent Containers ===');
  console.log(JSON.stringify(messageInputContainer, null, 2));
  
  // Final check: Look for any SVG icons that might be clickable
  const clickableIcons = await page.evaluate(() => {
    const svgs = document.querySelectorAll('svg');
    const clickable = [];
    
    svgs.forEach(svg => {
      const parent = svg.parentElement;
      if (parent && (parent.tagName === 'BUTTON' || parent.onclick || parent.style.cursor === 'pointer')) {
        const rect = parent.getBoundingClientRect();
        clickable.push({
          parentTag: parent.tagName,
          parentId: parent.id || 'none',
          bottom: rect.bottom,
          right: rect.right,
          visible: rect.width > 0 && rect.height > 0
        });
      }
    });
    
    return clickable.filter(icon => icon.bottom > 350);
  });
  
  console.log('\n=== Clickable Icons near bottom ===');
  console.log(JSON.stringify(clickableIcons, null, 2));
  
  // Take a screenshot focused on the input area
  await page.screenshot({ 
    path: 'test-results/input-area-focus.png',
    clip: { x: 0, y: 300, width: 1280, height: 400 }
  });
});