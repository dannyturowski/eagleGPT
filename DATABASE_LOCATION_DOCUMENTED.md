# Database Location - CRITICAL DOCUMENTATION

## ⚠️ NEVER CHANGE THE DATABASE VOLUME MOUNTS ⚠️

### Current Correct Configuration
```yaml
volumes:
  # ⚠️ CRITICAL: This path contains all 7 users and 27+ chats - DO NOT CHANGE!
  - /opt/openwebui/data:/app/backend/data
  # ⚠️ CRITICAL: Backup location - DO NOT CHANGE!  
  - /opt/openwebui/backup:/app/backup
```

### User Database Location
**Correct Database**: `/opt/openwebui/data/webui.db`
- Contains **7 registered users**
- Contains **27+ chat conversations** 
- Contains all user profiles, settings, and authentication data

### Users in Database (Verified June 2025)
1. **Danny Turowski** (turowski@gmail.com) - admin
2. **Ev** (everanc@gmail.com) - user  
3. **Min** (taomin@gmail.com) - user
4. **Jm** (justin@mahoodfam.com) - user
5. **TabTabs** (tabithakirkland@gmail.com) - user
6. **Elizabeth Paino** (elizabethturowski@gmail.com) - user
7. **John Kirkland** (frizwhiz@roadrunner.com) - user

### What Happens If You Change Volume Mounts
❌ **Users will appear to be missing**  
❌ **Chat history will be lost**  
❌ **Application will appear to have only 1 user**  
❌ **All user data becomes inaccessible**  

### Other Database Locations (DO NOT USE)
- `/mnt/HC_Volume_102716551/openwebui/data/webui.db` - Incomplete database with only 1 user
- Any other path - Will result in data loss

### Recovery Process (If Accidentally Changed)
If someone accidentally changes the volume mounts:
1. Stop the container
2. Update docker-compose.yml to use `/opt/openwebui/data:/app/backend/data`  
3. Restart the container
4. Verify all 7 users are accessible

### File Locations
- **Docker Compose**: `/opt/openwebui/docker-compose.yml`
- **Database**: `/opt/openwebui/data/webui.db` 
- **Backup**: `/opt/openwebui/backup/`

## REMEMBER: /opt/openwebui/data is the ONLY correct database location!