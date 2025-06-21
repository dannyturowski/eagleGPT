import { goto } from '$app/navigation';
import { toast } from 'svelte-sonner';
import { get } from 'svelte/store';
import { user } from '$lib/stores';

/**
 * Check if the current user is a demo user
 * @returns {boolean}
 */
export function isDemoUser() {
    const currentUser = get(user);
    return currentUser?.is_demo === true;
}

/**
 * Show demo restriction message and redirect to auth
 * @param {string} action - Optional description of the restricted action
 */
export function showDemoRestriction(action = null) {
    const message = action 
        ? `Demo users cannot ${action}. Sign up for full access!`
        : 'Sign up to start your own conversations!';
    
    toast.error(message, {
        action: {
            label: 'Sign Up',
            onClick: () => goto('/auth')
        },
        duration: 5000
    });
}

/**
 * Check if demo user and show restriction if true
 * @param {string} action - Optional description of the restricted action
 * @returns {boolean} - Returns true if user is demo (restricted), false otherwise
 */
export function checkDemoRestriction(action = null) {
    if (isDemoUser()) {
        showDemoRestriction(action);
        return true;
    }
    return false;
}