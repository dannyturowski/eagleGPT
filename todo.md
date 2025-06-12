# TODO for Claude Code for eagleGPT

We are forking eagleGPT from openwebUI: https://github.com/dannyturowski/eagleGPT

We want our edits to be surgical where possible so that we can ingest upstream updates with as little pain as possible.

It is a satire site at https://eagleGPT.us

It is hosted on a VPS at 95.217.152.30. This is the docker context 'helsinki1'
You can SSH in (ssh root@95.217.152.30) to make changes

## TO DO


- [ ] add "powered by OpenWebUI" branding to footer along with ko-fi + patreon links
- [ ] add call to action to footer linking to https://ko-fi.com/eaglegpt with a random rotating phrase:
	💰 Support freedom. Tip the eagle.
	🦅 Keep the eagle caffeinated and Constitutionally angry.
	📡 Donate now — before the Deep State shuts us down.
	🧢 Buy ammo for the logic cannon.
	🇺🇸 Fuel liberty. One Ko-fi at a time.
	🔥 This AI runs on propane and patriotism. Chip in.
	🐔 Donate before this eagle becomes a chicken nugget.
	🧠 Keep this brainwashed bird flying.
	🗽 Help us stand taller than a 5G tower.
	👓 Sunglasses don’t pay for themselves.
	📚 Every dollar protects one more banned book.
	🪖 Fund algorithmic vigilance against woke infiltrators.
	🎖️ Donate and receive a free invisible Medal of Freedom.
	🌪️ Keep spinning freedom at high RPMs.
	💂 Support the only bird brave enough to recite the Pledge backwards.
	📦 Your donation keeps the bunker stocked with red, white, and beans.
	🦤 Keep liberty alive. Don’t let EagleGPT go the way of the dodo.
	🥓 Support AI that’s 100% gluten-free and 1776-compliant.
	🧱 Build a wall around our server costs. Donate today.
	🛰️ Your funds help deflect liberal brainwaves from orbit.
- [x] change page title from 'Open WebUI' to 'eagleGPT'
- [x] add favicon from /assets/eagleGPT-1.png
- [ ] set the default chat background image for everyone to /assets/flag-background-2.png
- [ ] OWUI currently:
		Shows the login screen first (/auth)
		Redirects after login to the main chat UI (/)
		I want: The default route / to show the patriotic splash page as-if the user were logged in, as a preview of what's possible.
		Actions like prompt submission to redirect to login if the user isn’t authenticated
- [ ] ability for admin to disable settings visibility for users globally
- [ ] implement rate limiting, likely thru openwebUI pipelines
- [ ] make number of prompt suggestions on home page configurable 

## DONE
- [x] clone the fork: https://github.com/dannyturowski/eagleGPT
- [x] make sharing links visible publicly, i.e. without login. should be toggle-able from admin panel