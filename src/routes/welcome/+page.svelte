<script lang="ts">
	import { onMount } from 'svelte';
	import { goto } from '$app/navigation';

	// Redirect to root page since anonymous access is now enabled there
	onMount(() => {
		goto('/');
	});
</script>

<!-- This page is deprecated - redirecting to root -->