# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a fork of OpenWebUI (https://github.com/dannyturowski/eagleGPT) - a satirical AI chat interface hosted at https://eagleGPT.us.

We want our edits to be surgical where possible so that we can ingest upstream updates with as little pain as possible.

## Development Environment

- **Production Server**: VPS at 95.217.152.30
- **Docker Context**: `helsinki1`
- **SSH Access**: `ssh root@95.217.152.30`

## Key Customizations Needed

1. **Public Sharing Links**: Implement toggle-able public visibility for chat sharing links (currently requires login)
2. **Branding**: Add "powered by OpenWebUI" footer with Ko-fi and Patreon donation links
3. **Assets**:
   - Favicon: Use `/assets/eagleGPT-1.png`
   - Default chat background: Use `/assets/flag-background-2.png` for all users
4. **Authentication Flow**: 
   - Change default route `/` to show patriotic splash page as preview (without requiring login)
   - Redirect to `/auth` only when user attempts actions requiring authentication
5. **Admin Controls**: Add ability for admins to disable additional settings

## OpenWebUI Architecture

The codebase follows OpenWebUI's structure:
- **Backend**: FastAPI application in `/backend/` with SQLite database
- **Frontend**: SvelteKit application in `/src/` 
- **Docker**: Containerized deployment via `docker-compose.yml`
- **Authentication**: JWT-based auth system with login/signup flow
- **Chat Sharing**: Share functionality in `/backend/open_webui/routers/chats.py`

### Key Files for Customizations

1. **Authentication Flow**:
   - Frontend auth page: `/src/routes/auth/+page.svelte`
   - Backend auth routes: `/backend/open_webui/routers/auths.py`
   - Main app layout: `/src/routes/(app)/+layout.svelte`

2. **Branding & Assets**:
   - Static assets: `/static/` directory
   - Favicon configuration: `/src/app.html`
   - Background images: Configure in layout components

3. **Sharing Links**:
   - Backend routes: `/backend/open_webui/routers/chats.py`
   - Frontend share modal: `/src/lib/components/chat/ShareChatModal.svelte`

4. **Admin Settings**:
   - Config: `/backend/open_webui/config.py`
   - Admin routes: `/backend/open_webui/routers/admin.py`

## Development Commands

```bash
# Frontend development
npm install
npm run dev  # Runs on http://localhost:5173

# Backend development  
cd backend
pip install -r requirements.txt
python -m open_webui.main  # Runs on http://localhost:8080

# Full stack with Docker
docker compose up -d  # Runs on http://localhost:3000

# Deploy to production
docker context use hel1
docker compose up -d

# Run tests
npm test  # Frontend tests
cd backend && pytest  # Backend tests
```

## Important Notes

- This is a satire site with patriotic theming
- Production deployment uses Docker on the VPS
- Assets for customization are already prepared in `/assets/` directory