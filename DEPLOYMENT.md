# EagleGPT Deployment Guide

## Important: Data Persistence

**CRITICAL**: The existing OpenWebUI installation uses **bind mounts**, not Docker volumes!

- Data location: `/opt/openwebui/data`
- Backup location: `/opt/openwebui/backup`
- Config location: `/opt/openwebui/docker-compose.yml`

## What Went Wrong

The initial deployment scripts created a new Docker volume (`eaglegpt-data`) instead of using the existing bind mounts. This caused the container to start with empty data, requiring re-registration.

## Correct Deployment Process

### 1. Build Locally
```bash
docker build -t eaglegpt:latest .
```

### 2. Save and Transfer
```bash
docker save eaglegpt:latest -o /tmp/eaglegpt-image.tar
cat /tmp/eaglegpt-image.tar | docker --context hel1 load
```

### 3. Deploy with Correct Mounts
```bash
docker --context hel1 run -d \
    --name eaglegpt \
    --restart unless-stopped \
    -p 3000:8080 \
    -v /opt/openwebui/data:/app/backend/data \
    -v /opt/openwebui/backup:/app/backup \
    -e WEBUI_NAME="eagleGPT" \
    -e WEBUI_URL="http://95.217.152.30:3000" \
    -e WEBUI_SECRET_KEY="<from-env-file>" \
    -e ENABLE_SIGNUP="true" \
    eaglegpt:latest
```

## Safe Deployment Scripts

### Option 1: Use the Config-Aware Script
```bash
./deploy-respecting-config.sh
```
This script:
- Checks for existing docker-compose.yml
- Uses the correct bind mount paths
- Preserves environment variables from .env

### Option 2: Use Docker Compose
```bash
# On the server at /opt/openwebui
docker-compose down
docker-compose up -d
```

## Verification Checklist

Before deploying:
- [ ] Check existing volume mounts: `docker inspect <container> | grep Mounts -A 10`
- [ ] Verify data directory: `ls -la /opt/openwebui/data`
- [ ] Check for docker-compose.yml: `cat /opt/openwebui/docker-compose.yml`

After deploying:
- [ ] Verify container uses bind mounts: `docker inspect eaglegpt | grep -A 10 Mounts`
- [ ] Check data is accessible: `docker exec eaglegpt ls -la /app/backend/data`
- [ ] Confirm login works with existing credentials

## Key Differences

### ❌ Wrong (Creates new volume):
```yaml
volumes:
  - eaglegpt-data:/app/backend/data  # This creates a Docker volume
```

### ✅ Correct (Uses existing data):
```yaml
volumes:
  - ./data:/app/backend/data  # This uses bind mount to host directory
  - ./backup:/app/backup
```

## Emergency Recovery

If you accidentally use the wrong volume again:

1. Stop the container: `docker stop eaglegpt`
2. Remove it: `docker rm eaglegpt`
3. Restart with correct mounts using the command above

## Notes

- The server uses `/opt/openwebui` as the base directory
- All data is on the attached block storage
- Never use `docker volume create` for this deployment
- Always use bind mounts to preserve existing data