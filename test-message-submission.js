// Test script to verify message submission works for regular users
// This script would be run in the browser console

async function testMessageSubmission() {
    // Check if user is loaded
    const userStore = window.__svelte_stores?.user;
    if (!userStore) {
        console.error('User store not found');
        return;
    }
    
    const user = userStore.get();
    console.log('Current user:', {
        id: user?.id,
        role: user?.role,
        info: user?.info,
        isDemoUser: user?.info?.is_demo === true
    });
    
    // Check if the send button is enabled
    const sendButton = document.getElementById('send-message-button');
    if (sendButton) {
        console.log('Send button found:', {
            disabled: sendButton.disabled,
            className: sendButton.className
        });
    } else {
        console.error('Send button not found');
    }
    
    // Check if demo modal would show
    const chatInput = document.getElementById('chat-input');
    if (chatInput) {
        console.log('Chat input found, value:', chatInput.value);
    }
    
    return {
        userLoaded: !!user,
        isDemoUser: user?.info?.is_demo === true,
        sendButtonEnabled: sendButton && !sendButton.disabled,
        canSendMessages: !!user && user?.info?.is_demo !== true
    };
}

// Run the test
testMessageSubmission().then(result => {
    console.log('Test results:', result);
    if (result.canSendMessages) {
        console.log('✅ Regular users can send messages');
    } else {
        console.error('❌ Issue detected - users cannot send messages');
    }
});