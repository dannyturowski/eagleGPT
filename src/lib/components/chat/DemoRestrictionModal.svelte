<script lang="ts">
	import { getContext } from 'svelte';
	import Modal from '../common/Modal.svelte';
	import { goto } from '$app/navigation';

	const i18n = getContext('i18n');

	export let show = false;
	export let action = 'create new chats';
</script>

<Modal bind:show size="sm">
	<div class="px-5 py-4 dark:text-gray-300">
		<div class="flex items-center gap-3 mb-4">
			<!-- American flag icon -->
			<div class="text-4xl">🇺🇸</div>
			<div>
				<div class="text-lg font-semibold text-gray-800 dark:text-gray-100">
					{$i18n.t('Join the Patriot Community!')}
				</div>
				<div class="text-sm text-gray-600 dark:text-gray-400">
					{$i18n.t('Demo mode is view-only')}
				</div>
			</div>
		</div>

		<div class="mb-6 text-sm text-gray-700 dark:text-gray-300">
			<p class="mb-3">
				{$i18n.t('You\'re currently browsing in demo mode. To {{action}}, you\'ll need to create a free account.', { action })}
			</p>
			<p class="font-medium">
				{$i18n.t('Join thousands of patriots using eagleGPT to fight back against Big Tech censorship!')}
			</p>
		</div>

		<div class="flex gap-3">
			<button
				class="flex-1 px-4 py-2.5 text-sm font-medium text-white bg-blue-600 hover:bg-blue-700 rounded-lg transition-colors flex items-center justify-center gap-2"
				on:click={() => {
					show = false;
					goto('/auth');
				}}
			>
				<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20" fill="currentColor" class="w-4 h-4">
					<path d="M10 8a3 3 0 1 0 0-6 3 3 0 0 0 0 6ZM3.465 14.493a1.23 1.23 0 0 0 .41 1.412A9.957 9.957 0 0 0 10 18c2.31 0 4.438-.784 6.131-2.1.43-.333.604-.903.408-1.41a7.002 7.002 0 0 0-13.074.003Z" />
				</svg>
				{$i18n.t('Sign Up Free')}
			</button>
			<button
				class="px-4 py-2.5 text-sm font-medium text-gray-700 dark:text-gray-300 bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 rounded-lg transition-colors"
				on:click={() => {
					show = false;
				}}
			>
				{$i18n.t('Continue Browsing')}
			</button>
		</div>
	</div>
</Modal>