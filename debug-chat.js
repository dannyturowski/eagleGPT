// Debug script to check why messages aren't being sent
// Run this in the browser console while logged in as admin

// Check user store
const userStore = window.__svelte_stores?.user;
if (userStore) {
    const user = userStore.get();
    console.log('Current user:', user);
    console.log('User info:', user?.info);
    console.log('Is demo?', user?.info?.is_demo);
} else {
    console.log('User store not found');
}

// Check if isDemoUser function exists
if (typeof isDemoUser !== 'undefined') {
    console.log('isDemoUser result:', isDemoUser());
} else {
    console.log('isDemoUser function not found in global scope');
}

// Try to submit a test message
const chatInput = document.querySelector('#chat-input');
if (chatInput) {
    console.log('Chat input found');
    chatInput.value = 'Test message';
    const event = new KeyboardEvent('keydown', {
        key: 'Enter',
        keyCode: 13,
        bubbles: true
    });
    chatInput.dispatchEvent(event);
} else {
    console.log('Chat input not found');
}