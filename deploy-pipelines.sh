#!/bin/bash

echo "🚀 Deploying OpenWebUI Pipelines Server for Rate Limiting"
echo "========================================================"

# Ensure pipelines directory exists
mkdir -p pipelines

# Create docker network if it doesn't exist
docker network create eaglegpt-network 2>/dev/null || true

# Stop existing pipeline container if running
docker stop eaglegpt_pipelines 2>/dev/null || true
docker rm eaglegpt_pipelines 2>/dev/null || true

# Start pipeline server
echo "📦 Starting pipeline server..."
docker-compose -f docker-compose.pipelines.yml up -d

# Wait for service to be ready
echo "⏳ Waiting for pipeline server to start..."
sleep 5

# Check if service is running
if docker ps | grep -q eaglegpt_pipelines; then
    echo "✅ Pipeline server is running!"
    echo ""
    echo "📝 Next steps:"
    echo "1. The rate limit filter is available at: http://localhost:9099/pipelines"
    echo "2. In OpenWebUI Admin Panel:"
    echo "   - Go to Settings → Connections → OpenAI API"
    echo "   - Add a new connection with URL: http://localhost:9099"
    echo "   - Save the connection"
    echo "3. Then go to Settings → Pipelines"
    echo "   - You should see the 'Rate Limit Filter' available"
    echo "   - Configure the rate limits as needed"
    echo ""
    echo "Default Rate Limits:"
    echo "- 10 requests per minute"
    echo "- 50 requests per hour"
    echo "- 100 requests per 180 minutes (sliding window)"
else
    echo "❌ Failed to start pipeline server"
    echo "Check logs with: docker logs eaglegpt_pipelines"
fi