<script lang="ts">
	import { onMount, getContext } from 'svelte';
	import { goto } from '$app/navigation';
	import { user, models, config } from '$lib/stores';
	import { getModels } from '$lib/apis';
	import Chat from '$lib/components/chat/Chat.svelte';
	import { toast } from 'svelte-sonner';

	const i18n = getContext('i18n');

	let loaded = false;

	onMount(async () => {
		// If user is already authenticated, redirect to main app
		if ($user) {
			goto('/');
			return;
		}

		// Load models for preview (empty array for unauthenticated users)
		await models.set([]);
		
		loaded = true;
	});

	// Intercept any action that requires authentication
	const authRequired = (action: string) => {
		toast.info($i18n.t('Please sign in to {{action}}', { action }));
		goto('/auth');
	};

	// Override prompt submission to require auth
	const handleSendPrompt = () => {
		authRequired('send messages');
	};

	// Override model selection to require auth
	const handleModelSelect = () => {
		authRequired('select models');
	};

	// Override any other interaction
	const handleInteraction = () => {
		authRequired('use this feature');
	};
</script>

<svelte:head>
	<title>Welcome to eagleGPT</title>
	<meta name="description" content="Experience eagleGPT - your intelligent AI assistant. Sign in to start chatting." />
</svelte:head>

{#if loaded}
	<div class="relative h-screen">
		<!-- Banner at top -->
		<div class="absolute top-0 left-0 right-0 z-20 bg-blue-600 text-white py-2 px-4 text-center">
			<div class="flex items-center justify-center space-x-2">
				<span class="text-sm font-medium">Welcome to eagleGPT! This is a preview mode.</span>
				<button
					on:click={() => goto('/auth')}
					class="ml-4 px-4 py-1 bg-white text-blue-600 text-sm font-semibold rounded-full hover:bg-blue-50 transition-colors"
				>
					Sign In to Chat
				</button>
			</div>
		</div>

		<!-- Main chat interface -->
		<div class="pt-10 h-full">
			<Chat
				chatId="preview"
				readOnly={true}
				on:send={handleSendPrompt}
				on:modelSelect={handleModelSelect}
				on:interaction={handleInteraction}
			/>
		</div>

		<!-- Overlay for interactions -->
		<div 
			class="absolute inset-0 z-10 pointer-events-none"
			on:click|capture|preventDefault={() => {
				const target = event.target as HTMLElement;
				// Check if user clicked on interactive elements
				if (target.tagName === 'BUTTON' || target.tagName === 'INPUT' || target.tagName === 'TEXTAREA') {
					event.stopPropagation();
					authRequired('use this feature');
				}
			}}
		/>
	</div>
{/if}