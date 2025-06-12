<script lang="ts">
	import { onMount, onDestroy } from 'svelte';
	import { getContext } from 'svelte';
	
	const i18n = getContext('i18n');
	
	// Rotating Ko-fi donation phrases from TODO list
	const kofiPhrases = [
		'💰 Support freedom. Tip the eagle.',
		'🦅 Keep the eagle caffeinated and Constitutionally angry.',
		'📡 Donate now — before the Deep State shuts us down.',
		'🧢 Buy ammo for the logic cannon.',
		'🇺🇸 Fuel liberty. One Ko-fi at a time.',
		'🔥 This AI runs on propane and patriotism. Chip in.',
		'🐔 Donate before this eagle becomes a chicken nugget.',
		'🧠 Keep this brainwashed bird flying.',
		'🗽 Help us stand taller than a 5G tower.',
		'👓 Sunglasses don\'t pay for themselves.',
		'📚 Every dollar protects one more banned book.',
		'🪖 Fund algorithmic vigilance against woke infiltrators.',
		'🎖️ Donate and receive a free invisible Medal of Freedom.',
		'🌪️ Keep spinning freedom at high RPMs.',
		'💂 Support the only bird brave enough to recite the Pledge backwards.',
		'📦 Your donation keeps the bunker stocked with red, white, and beans.',
		'🦤 Keep liberty alive. Don\'t let EagleGPT go the way of the dodo.',
		'🥓 Support AI that\'s 100% gluten-free and 1776-compliant.',
		'🧱 Build a wall around our server costs. Donate today.',
		'🛰️ Your funds help deflect liberal brainwaves from orbit.'
	];
	
	let currentPhraseIndex = 0;
	let interval: number | null = null;
	
	$: currentPhrase = kofiPhrases[currentPhraseIndex];
	
	onMount(() => {
		// Rotate phrases every 5 seconds
		interval = setInterval(() => {
			currentPhraseIndex = (currentPhraseIndex + 1) % kofiPhrases.length;
		}, 5000);
	});
	
	onDestroy(() => {
		if (interval) {
			clearInterval(interval);
		}
	});
</script>

<div class="footer-container px-2 py-3 border-t border-gray-100 dark:border-gray-800">
	<div class="flex flex-col gap-2 text-xs text-gray-500 dark:text-gray-400">
		<!-- Powered by OpenWebUI -->
		<div class="flex items-center justify-center gap-1">
			<span>Powered by</span>
			<a
				href="https://openwebui.com"
				target="_blank"
				rel="noopener noreferrer"
				class="text-gray-700 dark:text-gray-300 hover:text-gray-900 dark:hover:text-gray-100 transition-colors font-medium"
			>
				OpenWebUI
			</a>
		</div>
		
		<!-- Ko-fi Donation Link with Rotating Phrases -->
		<div class="flex items-center justify-center">
			<a
				href="https://ko-fi.com/eaglegpt"
				target="_blank"
				rel="noopener noreferrer"
				class="flex items-center gap-1.5 px-3 py-1.5 rounded-full bg-gray-100 dark:bg-gray-800 hover:bg-gray-200 dark:hover:bg-gray-700 transition-all duration-200 group"
			>
				<svg
					class="w-4 h-4 text-gray-600 dark:text-gray-400 group-hover:text-gray-800 dark:group-hover:text-gray-200 transition-colors"
					viewBox="0 0 24 24"
					fill="currentColor"
					xmlns="http://www.w3.org/2000/svg"
				>
					<path d="M20.216 6.415l-.132-.666c-.119-.598-.388-1.163-1.001-1.379-.197-.069-.42-.098-.57-.241-.152-.143-.196-.366-.231-.572-.065-.378-.125-.756-.192-1.133-.057-.325-.102-.69-.25-.987-.195-.4-.597-.634-.996-.788a5.723 5.723 0 00-.626-.194c-1-.263-2.05-.36-3.077-.416a25.834 25.834 0 00-3.7.062c-.915.083-1.88.184-2.75.5-.318.116-.646.256-.888.501-.297.302-.393.77-.177 1.146.154.267.415.456.692.58.36.162.737.284 1.123.366 1.075.238 2.189.331 3.287.37 1.218.05 2.437.01 3.65-.118.299-.033.598-.073.896-.119.352-.054.578-.513.474-.834-.124-.383-.457-.531-.834-.473-.466.074-.96.108-1.382.146-1.177.08-2.358.082-3.536.006a22.228 22.228 0 01-1.157-.107c-.086-.01-.18-.025-.258-.036-.243-.036-.484-.08-.724-.13-.111-.027-.111-.185 0-.212h.005c.277-.06.557-.108.838-.147h.002c.131-.009.263-.032.394-.048a25.076 25.076 0 013.426-.12c.674.019 1.347.067 2.017.144l.228.031c.267.04.533.088.798.145.392.085.895.113 1.07.542.055.137.08.288.111.431l.319 1.484a.237.237 0 01-.199.284h-.003c-.037.006-.075.01-.112.015a36.704 36.704 0 01-4.743.295 37.059 37.059 0 01-4.699-.304c-.14-.017-.293-.042-.417-.06-.326-.048-.649-.108-.973-.161-.393-.065-.768-.032-1.123.161-.29.16-.527.404-.675.701-.154.316-.199.66-.267 1-.069.34-.176.707-.135 1.056.087.753.613 1.365 1.37 1.502a39.69 39.69 0 0011.343.376.483.483 0 01.535.53l-.071.697-1.018 9.907c-.041.41-.047.832-.125 1.237-.122.637-.553 1.028-1.182 1.171-.577.131-1.165.2-1.756.205-.656.004-1.31-.025-1.966-.022-.699.004-1.556-.06-2.095-.58-.475-.458-.54-1.174-.605-1.793l-.731-7.013-.322-3.094c-.037-.351-.286-.695-.678-.678-.336.015-.718.3-.678.679l.228 2.185.949 9.112c.147 1.344 1.174 2.068 2.446 2.272.742.12 1.503.144 2.257.156.966.016 1.942.053 2.908-.078.94-.128 1.858-.457 2.22-1.476.225-.632.166-1.296.173-1.962.01-.91.024-1.82.06-2.73.024-.607.043-1.214.07-1.82l.103-1.999a.478.478 0 01.535-.53z"/>
				</svg>
				<span class="text-gray-700 dark:text-gray-300 font-medium transition-all duration-300">
					{currentPhrase}
				</span>
			</a>
		</div>
	</div>
</div>

<style>
	.footer-container {
		margin-top: auto;
	}
</style>