# Final Pipeline Connection Instructions

## Update Your Connection in OpenWebUI Admin Panel

The pipeline server is now properly configured with authentication. Update your connection with these exact details:

### Connection Settings:

1. Go to **Settings** → **Connections** → **OpenAI API**
2. Edit or create the pipeline connection with:

   - **Name**: Pipeline Server (or any name)
   - **API Base URL**: `http://eaglegpt_pipelines:9099`
   - **API Key**: `sk-eaglegpt-pipeline-key`

3. Click **Save**

### Verify It Works:

1. After saving, you should see a green checkmark or success indicator
2. Go to **Settings** → **Pipelines**
3. You should now see two pipelines:
   - **Rate Limit Filter**
   - **Rate Limit Filter (Redis)**

### Important Notes:

- The API key MUST be exactly: `sk-eaglegpt-pipeline-key`
- The URL MUST be: `http://eaglegpt_pipelines:9099` (not localhost!)
- Make sure there are no trailing slashes in the URL

### If It Still Doesn't Work:

Try these alternative URLs in order:
1. `http://eaglegpt_pipelines:9099/v1`
2. `http://eaglegpt_pipelines:9099`

### Test Command:

You can verify the connection from the server:
```bash
curl -H "Authorization: Bearer sk-eaglegpt-pipeline-key" http://localhost:9099/v1/models
```

This should return a JSON with both rate limit filters listed.