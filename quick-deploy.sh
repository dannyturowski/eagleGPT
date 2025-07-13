#!/bin/bash
set -e

echo "Quick deployment script for frontend changes"

# Build frontend only
echo "Building frontend..."
npm run build

# Create a tarball of the build
echo "Creating deployment package..."
tar -czf frontend-update.tar.gz build/

# Upload to server
echo "Uploading to server..."
scp frontend-update.tar.gz root@95.217.152.30:/tmp/

# Apply update on server
echo "Applying update..."
ssh root@95.217.152.30 << 'EOF'
cd /tmp
# Stop container temporarily
docker stop eaglegpt || true

# Extract and copy files
tar -xzf frontend-update.tar.gz
docker run --rm -v /tmp/build:/src -v eaglegpt_data:/data alpine sh -c "cp -r /src/* /data/frontend-build/"

# Start container
docker start eaglegpt || docker compose up -d

# Cleanup
rm -rf /tmp/build /tmp/frontend-update.tar.gz
EOF

echo "Deployment complete!"