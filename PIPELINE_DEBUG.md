# Pipeline Connection Debugging Steps

## Current Situation
The pipeline server is running correctly and responding with the proper format, but OpenWebUI isn't showing the pipelines in the admin panel.

## Please Try These Steps:

### 1. First, Clear Browser Cache
- Hard refresh the OpenWebUI page (Ctrl+F5 or Cmd+Shift+R)
- Or open in an incognito/private browser window

### 2. Re-add the Connection with These Exact Steps:

1. Go to **Settings** → **Connections**
2. Look for any existing pipeline connections and **DELETE** them
3. Click **"+ New Connection"** or **"Add"**
4. Fill in:
   - **API Base URL**: `http://eaglegpt_pipelines:9099`
   - **API Key**: `sk-eaglegpt-pipeline-key`
5. Click **Save**

### 3. Check Different Menu Locations:
After saving, check ALL of these locations:
- **Settings** → **Admin** → **Pipelines**
- **Settings** → **Functions** → **Pipelines**  
- **Settings** → **Pipelines**
- **Admin Settings** → **Pipelines**

### 4. While You Do This, I'll Monitor Logs

Run this command in your terminal to watch the logs:
```bash
docker logs -f eaglegpt_pipelines
```

When you save the connection or navigate to the pipelines page, you should see requests like:
- `GET /models` or `GET /v1/models`
- `GET /pipelines`

### 5. Alternative Test
Try accessing this URL directly in your browser while logged into OpenWebUI:
```
https://eaglegpt.us/api/v1/pipelines/list
```

This should show if OpenWebUI is recognizing any pipeline servers.

## If Still Not Working

### Check OpenWebUI Version
The pipeline feature may require a specific OpenWebUI version. Run:
```bash
docker exec openwebui cat /app/backend/open_webui/__init__.py | grep VERSION
```

### Manual Verification
Even if the UI doesn't show pipelines, they ARE working. Test directly:
```bash
# This shows the pipelines are loaded
curl -H "Authorization: Bearer sk-eaglegpt-pipeline-key" http://localhost:9099/pipelines
```

## Important Notes
- OpenWebUI was just restarted, so any cached connections should be cleared
- The pipeline server is confirmed working with the correct authentication
- The issue appears to be with OpenWebUI's UI recognizing the connection

Please let me know what you see in the logs when you try to access the pipelines page!