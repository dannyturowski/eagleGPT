# Pipeline Connection Troubleshooting Guide

## Current Status
✅ Pipeline server is running at port 9099
✅ Both rate limit filters are loaded
✅ API authentication is configured with key: `sk-eaglegpt-pipeline-key`
✅ Container-to-container connectivity is working
✅ All required API endpoints are available

## Exact Configuration Steps

### 1. In OpenWebUI Admin Panel

1. Go to **Settings** → **Connections**
2. Look for the **"External"** or **"OpenAI API"** section
3. Click **"+ Add"** or **"New Connection"**

### 2. Enter These EXACT Values

```
API Base URL: http://eaglegpt_pipelines:9099
API Key: sk-eaglegpt-pipeline-key
```

⚠️ **CRITICAL**: 
- Do NOT add `/v1` to the URL
- Do NOT use `localhost` or `127.0.0.1`
- Do NOT add trailing slashes
- The API key MUST be exactly as shown

### 3. Save and Verify

After saving:
1. You should see a green checkmark ✓ or "Connected" status
2. Navigate to **Settings** → **Functions** → **Pipelines**
3. You should see:
   - Rate Limit Filter
   - Rate Limit Filter (Redis)

## If Pipelines Still Don't Appear

### Option A: Try Alternative URL Format
Some versions of OpenWebUI expect the /v1 suffix:
```
API Base URL: http://eaglegpt_pipelines:9099/v1
API Key: sk-eaglegpt-pipeline-key
```

### Option B: Check OpenWebUI Version
The pipeline interface may be under different menu locations:
- **Settings** → **Functions** → **Pipelines**
- **Settings** → **Pipelines**
- **Admin** → **Pipelines**

### Option C: Direct Database Check
Check if the connection was saved in the database:

```bash
# Check OpenWebUI database for connections
docker exec openwebui sqlite3 /app/backend/data/webui.db "SELECT * FROM openai_connections;" 2>/dev/null || echo "Table may not exist"

# Check for any pipeline-related tables
docker exec openwebui sqlite3 /app/backend/data/webui.db ".tables" | grep -i pipeline
```

## Manual Test Commands

### 1. Test from your host machine:
```bash
curl -H "Authorization: Bearer sk-eaglegpt-pipeline-key" http://localhost:9099/v1/models
```

### 2. Test from OpenWebUI container:
```bash
docker exec openwebui curl -H "Authorization: Bearer sk-eaglegpt-pipeline-key" http://eaglegpt_pipelines:9099/v1/models
```

### 3. Check pipeline server logs:
```bash
docker logs eaglegpt_pipelines --tail 20 -f
```

## Common Issues and Solutions

### Issue: "Connection refused"
- **Cause**: Containers not on same network
- **Solution**: Already fixed - both containers are on `eaglegpt-network`

### Issue: "Not authenticated"
- **Cause**: Missing or incorrect API key
- **Solution**: Use exactly `sk-eaglegpt-pipeline-key`

### Issue: "No pipelines found"
- **Cause**: Wrong URL format or OpenWebUI version compatibility
- **Solution**: Try both URL formats (with and without /v1)

### Issue: Can't find Pipelines menu
- **Cause**: Different OpenWebUI version or configuration
- **Solution**: Check under Settings → Functions or Admin → Functions

## Next Steps After Connection Works

1. **Enable Rate Limiting**:
   - Click on "Rate Limit Filter" in the Pipelines menu
   - Toggle it to "Enabled"
   - Configure limits as needed

2. **Test Rate Limiting**:
   - Log out and test as a non-admin user
   - Make rapid requests to trigger the limit

3. **Monitor Logs**:
   ```bash
   docker logs -f eaglegpt_pipelines
   ```

## Emergency Fallback

If the UI connection absolutely won't work, you can verify the pipeline is functional by testing rate limiting directly:

```bash
# Make 15 rapid requests as a test
for i in {1..15}; do
  echo "Request $i:"
  curl -X POST http://localhost:9099/v1/chat/completions \
    -H "Authorization: Bearer sk-eaglegpt-pipeline-key" \
    -H "Content-Type: application/json" \
    -d '{"model": "rate_limit_filter", "messages": [{"role": "user", "content": "Test"}]}'
  echo ""
  sleep 0.5
done
```