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

# Full stack with Docker (LOCAL DEVELOPMENT ONLY)
# ⚠️  NEVER run this on production server - use deployment commands below!
docker compose up -d  # Runs on http://localhost:3000

# Build and deploy to production (RECOMMENDED)
# Build locally and push to GHCR to avoid timeout issues
docker build -t ghcr.io/dannyturowski/eaglegpt:latest .
docker push ghcr.io/dannyturowski/eaglegpt:latest

# Then on the server (or using helsinki1 context)
docker context use helsinki1
docker pull ghcr.io/dannyturowski/eaglegpt:latest
docker stop eaglegpt && docker rm eaglegpt
docker compose up -d

# 🚨 CRITICAL DATABASE VOLUME WARNING 🚨
# ALWAYS use docker-compose for deployment
# NEVER use docker run directly - it will reset the database to admin registration!
# NEVER change the bind mount paths in docker-compose.yml - they contain production data!
# 
# The ONLY CORRECT production database is stored at:
# /mnt/HC_Volume_102716551/openwebui/data/webui.db (on Helsinki server block storage)
#
# ⚠️ DO NOT USE /opt/openwebui/data - that contains OLD BACKUPS ONLY! ⚠️
#
# If you see the admin registration page, you've broken the volume configuration!
# Correct volumes in docker-compose.yml MUST BE:
#   - /mnt/HC_Volume_102716551/openwebui/data:/app/backend/data
#   - /mnt/HC_Volume_102716551/openwebui/backup:/app/backup
#
# Production database details:
# - Location: /mnt/HC_Volume_102716551/openwebui/data/webui.db
# - Size: ~1.1MB
# - Users: 8 (Danny, Ev, Min, Jm, TabTabs, Elizabeth, John, Demo User)
# - Last verified: July 2025

# Alternative: Direct deployment (may timeout due to ML dependencies)
docker context use helsinki1
docker compose up -d --build

# Run tests
npm test  # Frontend tests
cd backend && pytest  # Backend tests
```

## Build Issues and Solutions

The frontend build process can be slow due to large ML dependencies (mermaid, onnxruntime-web, @huggingface/transformers). If builds hang during transformation:

1. **Use Docker for deployment** - The production Docker build includes optimizations
2. **Local development** - Use `npm run dev` for testing features  
3. **ML dependencies** - Consider dynamic imports for heavy packages to improve build times

## Demo Modal Implementation

✅ **Completed**: Demo restriction modal for anonymous users
- Location: `/src/lib/components/chat/DemoRestrictionModal.svelte`
- Integration: Updated `MessageInput.svelte` to show modal instead of submitting chats for demo users
- Features: Patriotic themed modal with "Sign Up Free" and "Continue Browsing" options
- Function: `isDemoUser()` checks if user is anonymous and shows appropriate restrictions

## Database Volume Troubleshooting

**🚨 If you see the admin registration page after deployment, you've broken the database volumes!**

### Symptoms:
- Site shows "Create Account" instead of login page
- All existing users and chats are gone
- Database appears to be reset

### Cause:
- Used `docker run` instead of `docker-compose`
- Changed the bind mount paths in docker-compose.yml
- Used named volumes instead of bind mounts

### Fix:
1. Stop the container: `docker stop eaglegpt && docker rm eaglegpt`
2. Verify docker-compose.yml has correct bind mounts:
   ```yaml
   volumes:
     - /mnt/HC_Volume_102716551/openwebui/data:/app/backend/data
     - /mnt/HC_Volume_102716551/openwebui/backup:/app/backup
   ```
3. Deploy with: `docker compose -f eaglegpt-compose.yml up -d`
4. Verify database exists: `ls -la /mnt/HC_Volume_102716551/openwebui/data/webui.db`

## Production Deployment Checklist

Before deploying, verify these critical points:

### ✅ Pre-deployment Checklist:
1. **docker-compose.yml verification:**
   - [ ] Uses `image: ghcr.io/dannyturowski/eaglegpt:latest` (not `build: .`)
   - [ ] Contains bind mounts: `/mnt/HC_Volume_102716551/openwebui/data:/app/backend/data`
   - [ ] Contains bind mounts: `/mnt/HC_Volume_102716551/openwebui/backup:/app/backup`
   - [ ] Does NOT use `data:` or `backup:` named volumes in the volumes section

2. **Deployment process:**
   - [ ] Use `docker compose -f eaglegpt-compose.yml up -d` (NEVER `docker run`)
   - [ ] Deploy on helsinki1 context: `docker context use helsinki1`

### ✅ Post-deployment Verification:
1. **Database check:**
   - [ ] Existing database file exists: `ls -la /mnt/HC_Volume_102716551/openwebui/data/webui.db`
   - [ ] File is recent (not newly created): check timestamp
   - [ ] File size > 1MB (not empty database)

2. **Site verification:**
   - [ ] Site responds: `curl http://95.217.152.30:3000`
   - [ ] Shows LOGIN page (not "Create Account" registration)
   - [ ] Existing users can log in
   - [ ] Demo modal works for anonymous users

### 🚨 If Something Goes Wrong:
- **Admin registration page = database volumes are wrong!**
- **Fix:** Stop container, verify docker-compose.yml paths, redeploy
- **Never** try to fix by changing database paths - restore correct ones

## Important Notes

- This is a satire site with patriotic theming
- Production deployment uses Docker on the VPS
- Assets for customization are already prepared in `/assets/` directory