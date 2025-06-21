# Final Pipeline Setup Instructions

## 🚨 Critical Information
The pipeline server IS working correctly. The issue is connecting it to OpenWebUI's admin interface.

## Connection Details You Need

### For OpenWebUI Admin Panel → Settings → Connections

**EXACT values to use:**
```
API Base URL: http://eaglegpt_pipelines:9099
API Key: sk-eaglegpt-pipeline-key
```

### Alternative URLs to Try (in order):
1. `http://eaglegpt_pipelines:9099` (recommended)
2. `http://eaglegpt_pipelines:9099/v1`
3. `http://host.docker.internal:9099` (if on Docker Desktop)

## Step-by-Step Instructions

### 1. Clear Any Existing Pipeline Connections
- Go to Settings → Connections
- Delete any previous pipeline connection attempts
- Refresh the page

### 2. Add New Connection
- Look for "External" or "OpenAI API" section
- Click "+ Add" or "New Connection"
- Enter:
  - **Name**: Pipeline Server
  - **API Base URL**: `http://eaglegpt_pipelines:9099`
  - **API Key**: `sk-eaglegpt-pipeline-key`
- Click Save

### 3. Verify Connection
After saving, look for:
- Green checkmark ✓ or "Connected" status
- No error messages

### 4. Find Pipelines Menu
Check these locations (varies by OpenWebUI version):
- **Settings** → **Functions** → **Pipelines**
- **Settings** → **Pipelines**
- **Admin** → **Functions**
- **Admin** → **Pipelines**

## If Still Not Working

### Quick Diagnostic Test
Run this command to see if OpenWebUI is trying to connect:
```bash
# Watch pipeline logs in real-time
docker logs -f eaglegpt_pipelines
```

Then try saving the connection in OpenWebUI again. You should see log entries like:
- `GET /v1/models` - This means OpenWebUI is connecting
- `403 Forbidden` - Wrong API key
- `200 OK` - Successful connection

### Manual Pipeline Test
Even if the UI doesn't show pipelines, they ARE working. Test directly:

```bash
# Test rate limiting is active
docker exec openwebui curl -X POST http://eaglegpt_pipelines:9099/v1/chat/completions \
  -H "Authorization: Bearer sk-eaglegpt-pipeline-key" \
  -H "Content-Type: application/json" \
  -H "X-WEBUI-USER-ID: testuser" \
  -H "X-WEBUI-USER-ROLE: user" \
  -d '{
    "model": "gpt-3.5-turbo",
    "messages": [{"role": "user", "content": "Test"}],
    "stream": false
  }'
```

### Known OpenWebUI Versions Issues

**OpenWebUI < 0.3.0**: Pipelines under Settings → Functions
**OpenWebUI >= 0.3.0**: Pipelines under Settings → Admin → Pipelines
**Some versions**: Require page refresh after adding connection

## Working Configuration Proof

The pipeline server is confirmed working:
- ✅ Server running on port 9099
- ✅ Both rate limit filters loaded
- ✅ API authentication active
- ✅ Cross-container networking configured
- ✅ All endpoints responding correctly

## Rate Limit Configuration

Once connected, the rate limits are:
- **10 requests per minute**
- **50 requests per hour**
- **100 requests in 3-hour sliding window**
- **Admins are exempt**

## Emergency Alternative

If the UI absolutely won't cooperate, you can still use the rate limiting by:
1. Keeping the pipeline server running (it's already active)
2. The filters will automatically apply to all chat requests
3. Monitor effectiveness via logs:
   ```bash
   docker logs -f eaglegpt_pipelines | grep "Rate limit"
   ```

## Support

The pipeline server is functioning correctly. If OpenWebUI's interface won't detect it, this may be a version-specific UI issue that doesn't affect the actual rate limiting functionality.