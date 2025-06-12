<script lang="ts">
	import { onMount, tick } from 'svelte';
	import { fade } from 'svelte/transition';
	import { cubicOut } from 'svelte/easing';

	export let handleGetStarted: () => void;

	let messages = [
		{
			id: 1,
			role: 'assistant',
			content: "👋 Welcome to eagleGPT! I'm your AI assistant, ready to help with anything you need. What would you like to explore today?",
			timestamp: Date.now() - 60000,
			typing: false
		}
	];

	let currentMessage = '';
	let isTyping = false;
	let showSuggestions = true;
	let inputValue = '';
	let messagesContainer: HTMLElement;

	const demoResponses = {
		"hello": "Hello! Great to meet you! I'm eagleGPT, your AI-powered assistant. I can help you with writing, analysis, coding, creative projects, and much more. What brings you here today? 🇺🇸",
		
		"what can you do": "I'm designed to be your versatile AI companion! Here's what I can help with:\n\n🎯 **Writing & Communication**\n- Draft emails, letters, and documents\n- Creative writing and storytelling\n- Proofreading and editing\n\n💼 **Business & Productivity**\n- Strategic planning and analysis\n- Meeting summaries and reports\n- Project management insights\n\n🧠 **Learning & Research**\n- Explain complex topics\n- Research assistance\n- Educational content creation\n\n💻 **Technical Support**\n- Code review and debugging\n- Technical documentation\n- Problem-solving guidance\n\nBuilt with American innovation and values! What would you like to tackle first?",

		"code": "I'd be happy to help with coding! Here's a quick example of a Python function:\n\n```python\ndef calculate_fibonacci(n):\n    \"\"\"Calculate the nth Fibonacci number efficiently.\"\"\"\n    if n <= 1:\n        return n\n    \n    a, b = 0, 1\n    for _ in range(2, n + 1):\n        a, b = b, a + b\n    \n    return b\n\n# Example usage\nresult = calculate_fibonacci(10)\nprint(f\"The 10th Fibonacci number is: {result}\")\n```\n\nI can help with Python, JavaScript, TypeScript, React, and many other technologies. What programming challenge can I assist you with?",

		"america": "🇺🇸 America represents the pinnacle of innovation, freedom, and opportunity! From the founding principles of life, liberty, and the pursuit of happiness to leading the world in technological advancement, America continues to be a beacon of hope and progress.\n\nSome incredible American achievements:\n- 🚀 Space exploration and moon landing\n- 💡 Revolutionary technologies and inventions\n- 🏛️ Democratic principles and constitutional government\n- 🎓 World-class universities and research institutions\n- 🤝 Diversity and the melting pot of cultures\n\nAs an AI built with American values, I'm here to embody that spirit of innovation and helpfulness. How can I assist you in achieving your goals today?",

		"default": "That's an interesting question! While this is just a preview of eagleGPT's capabilities, I can already tell you're curious about what AI can do. \n\nIn the full version, I can provide detailed responses on virtually any topic, help with complex tasks, engage in creative projects, and much more. \n\n🚀 Ready to unlock the full potential? Sign up to experience everything eagleGPT has to offer!"
	};

	const suggestions = [
		"👋 Say hello and introduce yourself",
		"🤔 What can you help me with?", 
		"💻 Show me some code examples",
		"🇺🇸 Tell me about America",
		"✨ What makes you special?"
	];

	const handleSuggestionClick = (suggestion: string) => {
		const cleanSuggestion = suggestion.replace(/^[👋🤔💻🇺🇸✨]\s/, '');
		handleSubmit(cleanSuggestion);
	};

	const handleSubmit = async (message?: string) => {
		const userMessage = message || inputValue.trim();
		if (!userMessage) return;

		// Add user message
		const userMsg = {
			id: Date.now(),
			role: 'user',
			content: userMessage,
			timestamp: Date.now(),
			typing: false
		};

		messages = [...messages, userMsg];
		inputValue = '';
		showSuggestions = false;
		isTyping = true;

		// Scroll to bottom
		await tick();
		scrollToBottom();

		// Simulate typing delay
		await new Promise(resolve => setTimeout(resolve, 1000 + Math.random() * 1000));

		// Generate response
		let response = demoResponses.default;
		const lowerMessage = userMessage.toLowerCase();

		if (lowerMessage.includes('hello') || lowerMessage.includes('hi') || lowerMessage.includes('hey')) {
			response = demoResponses.hello;
		} else if (lowerMessage.includes('what') && (lowerMessage.includes('can') || lowerMessage.includes('do') || lowerMessage.includes('help'))) {
			response = demoResponses["what can you do"];
		} else if (lowerMessage.includes('code') || lowerMessage.includes('program') || lowerMessage.includes('example')) {
			response = demoResponses.code;
		} else if (lowerMessage.includes('america') || lowerMessage.includes('usa') || lowerMessage.includes('united states')) {
			response = demoResponses.america;
		}

		// Add assistant message
		const assistantMsg = {
			id: Date.now() + 1,
			role: 'assistant',
			content: response,
			timestamp: Date.now(),
			typing: true
		};

		messages = [...messages, assistantMsg];
		isTyping = false;

		await tick();
		scrollToBottom();

		// After a delay, stop typing animation
		setTimeout(() => {
			messages = messages.map(msg => 
				msg.id === assistantMsg.id 
					? { ...msg, typing: false }
					: msg
			);
		}, response.length * 20 + 1000);
	};

	const scrollToBottom = () => {
		if (messagesContainer) {
			messagesContainer.scrollTop = messagesContainer.scrollHeight;
		}
	};

	const handleInputKeydown = (event: KeyboardEvent) => {
		if (event.key === 'Enter' && !event.shiftKey) {
			event.preventDefault();
			handleSubmit();
		}
	};

	onMount(() => {
		scrollToBottom();
	});
</script>

<div class="flex flex-col h-full bg-white dark:bg-gray-900">
	<!-- Messages -->
	<div 
		bind:this={messagesContainer}
		class="flex-1 overflow-y-auto px-4 py-4 space-y-4"
	>
		{#each messages as message (message.id)}
			<div class="flex {message.role === 'user' ? 'justify-end' : 'justify-start'}" in:fade={{ duration: 300 }}>
				<div class="flex max-w-[80%] {message.role === 'user' ? 'flex-row-reverse' : 'flex-row'} items-start space-x-2">
					<!-- Avatar -->
					<div class="flex-shrink-0 w-8 h-8 rounded-full {message.role === 'user' ? 'bg-blue-500 ml-2' : 'bg-gray-600 mr-2'} flex items-center justify-center">
						{#if message.role === 'user'}
							<span class="text-white text-sm font-medium">U</span>
						{:else}
							<span class="text-white text-sm font-medium">🦅</span>
						{/if}
					</div>
					
					<!-- Message bubble -->
					<div class="rounded-lg px-4 py-2 {message.role === 'user' 
						? 'bg-blue-500 text-white' 
						: 'bg-gray-100 dark:bg-gray-800 text-gray-900 dark:text-white border dark:border-gray-700'
					}">
						{#if message.typing}
							<div in:fade={{ delay: 100, duration: 300 }}>
								{@html message.content.replace(/\n/g, '<br>').replace(/```(\w+)?\n([\s\S]*?)```/g, '<pre class="bg-gray-900 text-green-400 p-3 rounded mt-2 overflow-x-auto"><code>$2</code></pre>')}
							</div>
						{:else}
							<div>
								{@html message.content.replace(/\n/g, '<br>').replace(/```(\w+)?\n([\s\S]*?)```/g, '<pre class="bg-gray-900 text-green-400 p-3 rounded mt-2 overflow-x-auto"><code>$2</code></pre>')}
							</div>
						{/if}
					</div>
				</div>
			</div>
		{/each}

		{#if isTyping}
			<div class="flex justify-start" in:fade={{ duration: 300 }}>
				<div class="flex items-start space-x-2">
					<div class="w-8 h-8 rounded-full bg-gray-600 flex items-center justify-center">
						<span class="text-white text-sm font-medium">🦅</span>
					</div>
					<div class="bg-gray-100 dark:bg-gray-800 rounded-lg px-4 py-2 border dark:border-gray-700">
						<div class="flex space-x-1">
							<div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce"></div>
							<div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.1s"></div>
							<div class="w-2 h-2 bg-gray-400 rounded-full animate-bounce" style="animation-delay: 0.2s"></div>
						</div>
					</div>
				</div>
			</div>
		{/if}

		{#if showSuggestions}
			<div class="space-y-2" in:fade={{ duration: 300, delay: 500 }}>
				<p class="text-sm text-gray-500 dark:text-gray-400 text-center">Try asking me about:</p>
				<div class="flex flex-wrap gap-2 justify-center">
					{#each suggestions as suggestion}
						<button
							on:click={() => handleSuggestionClick(suggestion)}
							class="px-3 py-2 bg-blue-50 dark:bg-blue-900 text-blue-700 dark:text-blue-200 rounded-lg text-sm hover:bg-blue-100 dark:hover:bg-blue-800 transition-colors border border-blue-200 dark:border-blue-700"
						>
							{suggestion}
						</button>
					{/each}
				</div>
			</div>
		{/if}
	</div>

	<!-- Input area -->
	<div class="border-t dark:border-gray-700 p-4">
		<!-- Preview notice -->
		<div class="mb-3 p-3 bg-amber-50 dark:bg-amber-900 border border-amber-200 dark:border-amber-700 rounded-lg">
			<div class="flex items-center justify-between">
				<div class="flex items-center space-x-2">
					<span class="text-amber-600 dark:text-amber-300">⚡</span>
					<span class="text-sm text-amber-700 dark:text-amber-200 font-medium">
						This is a preview with limited responses
					</span>
				</div>
				<button
					on:click={handleGetStarted}
					class="text-sm bg-amber-600 hover:bg-amber-700 text-white px-3 py-1 rounded transition-colors"
				>
					Unlock Full Access
				</button>
			</div>
		</div>

		<!-- Input -->
		<div class="flex space-x-2">
			<div class="flex-1 relative">
				<input
					bind:value={inputValue}
					on:keydown={handleInputKeydown}
					placeholder="Type your message... (Preview mode - limited responses)"
					class="w-full px-4 py-2 border dark:border-gray-600 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-gray-800 dark:text-white resize-none"
					disabled={isTyping}
				/>
				
				<!-- Overlay for click-to-login -->
				<button
					on:click={handleGetStarted}
					class="absolute inset-0 bg-transparent hover:bg-blue-500 hover:bg-opacity-10 rounded-lg flex items-center justify-center opacity-0 hover:opacity-100 transition-opacity"
					title="Sign up to unlock full chat capabilities"
				>
					<span class="text-blue-600 font-medium">🔓 Click to unlock full chat</span>
				</button>
			</div>
			
			<button
				on:click={() => handleSubmit()}
				disabled={isTyping || !inputValue.trim()}
				class="px-6 py-2 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white rounded-lg transition-colors disabled:cursor-not-allowed"
			>
				{#if isTyping}
					<div class="w-4 h-4 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
				{:else}
					Send
				{/if}
			</button>
		</div>
		
		<!-- Get started prompt -->
		<div class="mt-3 text-center">
			<button
				on:click={handleGetStarted}
				class="text-sm text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 font-medium"
			>
				Ready for the full experience? Get started now →
			</button>
		</div>
	</div>
</div>

<style>
	/* Custom scrollbar */
	:global(.overflow-y-auto::-webkit-scrollbar) {
		width: 6px;
	}
	
	:global(.overflow-y-auto::-webkit-scrollbar-track) {
		background: transparent;
	}
	
	:global(.overflow-y-auto::-webkit-scrollbar-thumb) {
		background: #d1d5db;
		border-radius: 3px;
	}
	
	:global(.dark .overflow-y-auto::-webkit-scrollbar-thumb) {
		background: #4b5563;
	}
</style>