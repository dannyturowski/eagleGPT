# Fix Pipeline Connection in OpenWebUI

## The Issue
When you added `http://localhost:9099`, it didn't work because:
1. Docker containers can't reach each other via `localhost`
2. The containers were on different Docker networks

## The Fix
I've connected both containers to the same network. Now update your connection:

### Step 1: Update the Connection URL

1. Go to **Settings** → **Connections** → **OpenAI API**
2. Find the connection you created for the pipeline server
3. **Change the URL from**: `http://localhost:9099`
4. **Change it to**: `http://eaglegpt_pipelines:9099`
5. Click **Save**

### Step 2: Verify Pipelines Appear

1. Go to **Settings** → **Pipelines**
2. You should now see:
   - Rate Limit Filter
   - Rate Limit Filter (Redis)

### Alternative URLs That Should Work:
- `http://eaglegpt_pipelines:9099` (recommended - uses container name)
- `http://host.docker.internal:9099` (if running on Docker Desktop)

### Troubleshooting

If pipelines still don't appear:

1. **Test the connection** from OpenWebUI container:
   ```bash
   docker exec openwebui curl http://eaglegpt_pipelines:9099/
   # Should return: {"status":true}
   ```

2. **Check container names**:
   ```bash
   docker ps --format "table {{.Names}}\t{{.Ports}}"
   ```

3. **Verify both containers are on the same network**:
   ```bash
   docker network inspect eaglegpt-network
   ```

4. **Check pipeline server logs**:
   ```bash
   docker logs eaglegpt_pipelines --tail 50
   ```

### Important Note
Always use container names (not localhost) when one Docker container needs to communicate with another!