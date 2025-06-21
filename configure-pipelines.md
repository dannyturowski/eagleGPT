# Configuring Rate Limiting in OpenWebUI

The pipeline server is now running at `http://localhost:9099`. Follow these steps to enable rate limiting:

## Step 1: Access OpenWebUI Admin Panel

1. Go to https://eaglegpt.us/admin
2. Log in with your admin credentials

## Step 2: Add Pipeline Server Connection

1. Navigate to **Settings** → **Connections** → **OpenAI API**
2. Click **"+ Add Connection"**
3. Enter the following:
   - **Name**: Pipeline Server (or any name you prefer)
   - **API Base URL**: `http://localhost:9099`
   - **API Key**: `pipeline-server-key` (any non-empty string works)
4. Click **Save**

## Step 3: Enable Rate Limiting

1. Go to **Settings** → **Pipelines**
2. You should see two available pipelines:
   - **Rate Limit Filter** - Basic in-memory rate limiting
   - **Rate Limit Filter (Redis)** - Persistent rate limiting with Redis support

3. Click on **"Rate Limit Filter"** to configure it
4. Review/adjust the settings:
   - **Requests per minute**: 10 (default)
   - **Requests per hour**: 50 (default)
   - **Sliding window limit**: 100 (default)
   - **Sliding window minutes**: 180 (default)
   - **Exempt admin**: true (admins bypass limits)

5. Click **Enable** or **Save**

## Step 4: Associate with Models

The rate limit filter is configured to apply to all models by default (pipelines: ["*"]).

If you want to apply it to specific models only:
1. Edit the pipelines list in the filter configuration
2. Add specific model IDs instead of "*"

## Testing Rate Limiting

Test with a non-admin user account:

```bash
# Make multiple requests quickly
for i in {1..15}; do
  curl -X POST https://eaglegpt.us/api/chat/completions \
    -H "Authorization: Bearer USER_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"model": "eagleGPT", "messages": [{"role": "user", "content": "Test"}]}'
  echo ""
  sleep 1
done
```

You should see HTTP 429 errors after exceeding 10 requests per minute.

## Monitoring

Check pipeline logs:
```bash
docker logs -f eaglegpt_pipelines
```

## Troubleshooting

If the pipeline server doesn't appear in connections:
1. Ensure the container is running: `docker ps | grep pipelines`
2. Check connectivity: `curl http://localhost:9099/health`
3. Verify network: Both containers should be on the same Docker network

If rate limiting isn't working:
1. Ensure the pipeline is enabled in Settings → Pipelines
2. Check that it's set to apply to all models (pipelines: ["*"])
3. Test with a non-admin user (admins are exempt by default)
4. Check logs for any errors