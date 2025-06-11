# TODO for Claude Code for eagleGPT

We are forking eagleGPT from openwebUI: https://github.com/dannyturowski/eagleGPT

We want our edits to be surgical where possible so that we can ingest upstream updates with as little pain as possible.

It is a satire site at https://eagleGPT.us

It is hosted on a VPS at 95.217.152.30. This is the docker context 'helsinki1'
You can SSH in (ssh root@95.217.152.30) to make changes

- [x] clone the fork: https://github.com/dannyturowski/eagleGPT
- [x] make sharing links visible publicly, i.e. without login. should be toggle-able from admin panel
- [ ] add "powered by OpenWebUI" branding to footer along with ko-fi + patreon links
- [ ] change page title from 'Open WebUI' to 'eagleGPT'
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