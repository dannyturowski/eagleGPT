# GitHub Container Registry (GHCR) Setup Guide

This guide will help you set up automated Docker builds and deployments using GitHub Container Registry.

## Benefits of Using GHCR

- **Faster builds**: GitHub Actions runners have better performance and caching
- **No local builds**: Everything happens in the cloud
- **Automatic deployments**: Push to main = automatic deployment
- **Better reliability**: No SSH connection issues
- **Free for public repos**: 500MB storage, 1GB bandwidth/month

## Setup Steps

### 1. Enable GitHub Actions

Your repository already has the workflow files in `.github/workflows/`

### 2. Update the deployment script

Edit `deploy-from-ghcr.sh` and replace `YOUR_GITHUB_USERNAME` with your actual GitHub username:

```bash
GHCR_IMAGE="ghcr.io/YOUR_GITHUB_USERNAME/eaglegpt:latest"
```

### 3. Set up the webhook server on your VPS (optional)

For automatic deployments, run the webhook server on your VPS:

```bash
# On your server
cd /opt
wget https://raw.githubusercontent.com/YOUR_USERNAME/eaglegpt/main/webhook-deploy-server.py
chmod +x webhook-deploy-server.py

# Create systemd service
sudo tee /etc/systemd/system/eaglegpt-webhook.service << EOF
[Unit]
Description=EagleGPT Deployment Webhook
After=network.target

[Service]
Type=simple
Environment="WEBHOOK_TOKEN=your-secret-token-here"
Environment="WEBHOOK_PORT=8888"
Environment="GHCR_IMAGE=ghcr.io/YOUR_USERNAME/eaglegpt:latest"
ExecStart=/usr/bin/python3 /opt/webhook-deploy-server.py
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl enable eaglegpt-webhook
sudo systemctl start eaglegpt-webhook
```

### 4. Configure GitHub Secrets

Go to your repository Settings → Secrets and variables → Actions, and add:

- `DEPLOY_WEBHOOK_URL`: `http://95.217.152.30:8888/`
- `DEPLOY_WEBHOOK_TOKEN`: Same token you set in the systemd service

### 5. First deployment

1. Push your code to GitHub:
   ```bash
   git add .
   git commit -m "Add GHCR workflows"
   git push origin main
   ```

2. Monitor the build in GitHub Actions tab

3. Once built, deploy manually the first time:
   ```bash
   # From your local machine
   ./deploy-from-ghcr.sh
   ```

## Manual Deployment

If you prefer manual deployments, just run this after each push:

```bash
docker --context hel1 pull ghcr.io/YOUR_USERNAME/eaglegpt:latest
docker --context hel1 stop eaglegpt && docker --context hel1 rm eaglegpt
docker --context hel1 run -d \
    --name eaglegpt \
    --restart unless-stopped \
    -p 3000:8080 \
    -v /opt/openwebui/data:/app/backend/data \
    -v /opt/openwebui/backup:/app/backup \
    -e WEBUI_NAME="eagleGPT" \
    -e WEBUI_URL="http://95.217.152.30:3000" \
    -e WEBUI_SECRET_KEY="$(openssl rand -hex 32)" \
    -e ENABLE_SIGNUP="true" \
    ghcr.io/YOUR_USERNAME/eaglegpt:latest
```

## Troubleshooting

1. **Build fails**: Check GitHub Actions logs
2. **Can't pull image**: Make sure the repository is public or you're authenticated
3. **Deployment fails**: Check webhook server logs with `journalctl -u eaglegpt-webhook -f`

## Current Build Issue

The local build is taking too long due to:
- Downloading all Pyodide packages during build
- Large Python dependencies
- Limited local resources

GHCR will solve this by:
- Using GitHub's fast build infrastructure
- Better Docker layer caching
- Parallel builds possible