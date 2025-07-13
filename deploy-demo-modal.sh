#!/bin/bash
set -e

echo "Building frontend locally..."
npm run build

echo "Creating deployment package..."
tar -czf demo-modal-update.tar.gz \
  build/_app/immutable/nodes/*.js \
  build/_app/immutable/chunks/*.js \
  build/demo-auto-login.js

echo "Copying to server..."
scp demo-modal-update.tar.gz root@95.217.152.30:/tmp/

echo "Applying update on server..."
ssh root@95.217.152.30 << 'EOF'
cd /tmp
tar -xzf demo-modal-update.tar.gz
docker exec eaglegpt sh -c "
  cp -r /tmp/build/_app/immutable/* /app/build/_app/immutable/ 2>/dev/null || true
  cp /tmp/build/demo-auto-login.js /app/build/ 2>/dev/null || true
"
rm demo-modal-update.tar.gz
EOF

echo "Update complete!"