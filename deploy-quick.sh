#!/bin/bash

# Quick deployment using pre-built image
echo "🚀 Quick EagleGPT Deployment"
echo "==========================="
echo ""

# Use the community Docker Hub image
docker --context hel1 run -d \
  --name eaglegpt \
  --restart unless-stopped \
  -p 3000:3000 \
  -v open-webui:/app/backend/data \
  -e WEBUI_NAME="eagleGPT" \
  -e WEBUI_URL="http://95.217.152.30:3000" \
  -e WEBUI_SECRET_KEY="$(openssl rand -hex 32)" \
  -e WEBUI_AUTH_TRUSTED_EMAIL_HEADER="" \
  -e ENABLE_SIGNUP="true" \
  --add-host=host.docker.internal:host-gateway \
  ghcr.io/open-webui/open-webui:main

echo "✅ Deployment complete!"
echo "🌐 Access at: http://95.217.152.30:3000"