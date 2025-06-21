<script>
	import { user } from '$lib/stores';
	import { isDemoUser } from '$lib/utils/demo';
	import { goto } from '$app/navigation';
</script>

{#if isDemoUser()}
	<div class="bg-blue-600 text-white px-4 py-2 text-center text-sm font-medium">
		<div class="max-w-screen-xl mx-auto flex items-center justify-center gap-4">
			<span>
				🦅 You're viewing eagleGPT as a demo user. Browse freely, but sign up to create your own conversations!
			</span>
			<button
				on:click={() => goto('/auth')}
				class="bg-white text-blue-600 px-4 py-1 rounded hover:bg-gray-100 transition-colors font-semibold"
			>
				Sign Up Free
			</button>
		</div>
	</div>
{/if}