# OpenWebUI Rate Limiting Pipeline

This directory contains rate limiting pipeline filters for OpenWebUI/eagleGPT.

## Available Filters

### 1. rate_limit_filter.py (Basic)
- In-memory storage (resets on restart)
- Simple and lightweight
- Good for testing and low-traffic sites

### 2. rate_limit_filter_redis.py (Advanced)
- Redis support for persistent storage
- Survives container restarts
- Better for production use

## Default Rate Limits

- 10 requests per minute
- 50 requests per hour
- 100 requests per 180-minute sliding window
- Admin users are exempt by default

## Installation

### Option 1: Using Pipeline Server (Recommended)

1. Deploy the pipeline server:
   ```bash
   ./deploy-pipelines.sh
   ```

2. In OpenWebUI Admin Panel:
   - Go to Settings → Connections → OpenAI API
   - Add connection: `http://localhost:9099`
   - Go to Settings → Pipelines
   - Enable the Rate Limit Filter

### Option 2: Direct Upload

1. In OpenWebUI Admin Panel:
   - Go to Settings → Pipelines
   - Click "Upload Pipeline"
   - Select `rate_limit_filter.py`
   - Configure rate limits in Valves

## Configuration

### Environment Variables

- `RATE_LIMIT_PER_MINUTE`: Requests per minute (default: 10)
- `RATE_LIMIT_PER_HOUR`: Requests per hour (default: 50)
- `RATE_LIMIT_SLIDING_WINDOW`: Max requests in sliding window (default: 100)
- `RATE_LIMIT_SLIDING_WINDOW_MINUTES`: Sliding window duration (default: 180)

### Redis Configuration (Advanced)

- `ENABLE_REDIS`: Enable Redis storage (default: false)
- `REDIS_URL`: Redis connection URL (default: redis://redis:6379/0)

## Testing

Test rate limiting with curl:

```bash
# Test as regular user
for i in {1..15}; do
  curl -X POST http://localhost:8080/api/chat/completions \
    -H "Authorization: Bearer YOUR_TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"model": "gpt-3.5-turbo", "messages": [{"role": "user", "content": "Hello"}]}'
  echo ""
done
```

You should see 429 errors after exceeding the rate limit.

## Monitoring

Check pipeline logs:
```bash
docker logs eaglegpt_pipelines
```

Check Redis (if enabled):
```bash
docker exec -it eaglegpt_redis redis-cli
> KEYS rate_limit:*
> GET rate_limit:USER_ID
```