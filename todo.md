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
- [x] set the default chat background image for everyone to /assets/flag-background-2.png
- [ ] OWUI currently:
		Shows the login screen first (/auth)
		Redirects after login to the main chat UI (/)
		I want: The default route / to show the patriotic splash page as-if the user were logged in, as a preview of what's possible.
		Actions like prompt submission to redirect to login if the user isn’t authenticated
- [ ] ability for admin to disable settings visibility for users globally
- [ ] implement rate limiting, likely thru openwebUI pipelines
- [x] make number of prompt suggestions on home page configurable 

## Anonymous User Homepage Design (Option 4 - Read-Only Showcase)

### Overview
Create a read-only showcase page for anonymous users that displays example conversations using the existing chat interface templates with hardcoded data.

### Layout Components

#### 1. Header Section
- **Model Selector**: 
  - Two models displayed side-by-side
  - Left: eagleGPT (with standard logo)
  - Right: TruePatriot (with custom logo)
  - Only one selectable at a time (other is greyed out)
  - Switching models changes the displayed conversations

#### 2. Background
- Use `flag-background-2.png` with reduced opacity/intensity
- Apply same overlay treatment as current chat interface

#### 3. Conversation Display
- **Thread List**: Show all conversation titles
- **Accordion Behavior**:
  - All threads start collapsed
  - Click on title to expand and view full conversation
  - Only one thread can be open at a time
  - Smooth expand/collapse animations
  
#### 4. Data Structure
```json
{
  "eagleGPT": {
    "threads": [
      {
        "id": "thread-1",
        "title": "Writing a Business Plan",
        "messages": [
          {
            "role": "user",
            "content": "Can you help me write a business plan for a tech startup?"
          },
          {
            "role": "assistant", 
            "content": "I'd be happy to help you create a business plan..."
          }
        ]
      }
    ]
  },
  "TruePatriot": {
    "threads": [
      {
        "id": "thread-1",
        "title": "Understanding the Constitution",
        "messages": [
          {
            "role": "user",
            "content": "What are the key principles of the US Constitution?"
          },
          {
            "role": "assistant",
            "content": "The US Constitution is built on several fundamental principles..."
          }
        ]
      }
    ]
  }
}
```

#### 5. Call to Action
- **Primary CTA Button**: 
  - Text: "Sign Up to Start Your Own Conversation"
  - Prominent placement (fixed bottom or after threads)
  - Links to `/auth` registration page
  - High contrast design for visibility

#### 6. Footer
- Include the previously created footer component with:
  - Branding information
  - Rotating Ko-fi donation phrases
  - Consistent styling with main app

### Technical Implementation

#### Components to Create/Modify:
1. **AnonymousShowcase.svelte**: New component for the showcase
2. **ThreadAccordion.svelte**: Reusable accordion component
3. **showcase-data.json**: Hardcoded conversation data

#### Integration Points:
- Detect anonymous users in Chat.svelte
- Render AnonymousShowcase instead of regular chat interface
- Reuse existing Message components for consistency
- Apply same styling and transitions

### User Flow
1. Anonymous user lands on homepage
2. Sees model selector with eagleGPT selected by default
3. Views list of example conversation titles
4. Clicks a title to expand and read the conversation
5. Can switch to TruePatriot model to see different conversations
6. Clicks CTA to register and start chatting

### Example Conversations to Include

#### eagleGPT Threads:
1. "Writing a Business Plan" - Entrepreneurship assistance
2. "Learning Python Programming" - Code education
3. "Planning a Healthy Meal Prep" - Lifestyle guidance
4. "Understanding Climate Change" - Educational content

#### TruePatriot Threads:
1. "Understanding the Constitution" - Civic education
2. "American History Timeline" - Historical overview
3. "Defending Individual Liberty" - Political philosophy
4. "The Founding Fathers' Vision" - Historical analysis

## DONE
- [x] clone the fork: https://github.com/dannyturowski/eagleGPT
- [x] make sharing links visible publicly, i.e. without login. should be toggle-able from admin panel