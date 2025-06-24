#!/bin/bash

echo "Updating server with demo mode files..."

# Copy files to server
scp backend/open_webui/routers/auths.py root@95.217.152.30:/tmp/auths.py
scp backend/open_webui/utils/auth.py root@95.217.152.30:/tmp/auth.py
scp backend/open_webui/config.py root@95.217.152.30:/tmp/config.py
scp backend/open_webui/main.py root@95.217.152.30:/tmp/main.py

# Copy files into container
ssh root@95.217.152.30 << 'EOF'
docker cp /tmp/auths.py eaglegpt:/app/backend/open_webui/routers/auths.py
docker cp /tmp/auth.py eaglegpt:/app/backend/open_webui/utils/auth.py
docker cp /tmp/config.py eaglegpt:/app/backend/open_webui/config.py
docker cp /tmp/main.py eaglegpt:/app/backend/open_webui/main.py

# Restart container
docker restart eaglegpt

# Clean up temp files
rm -f /tmp/auths.py /tmp/auth.py /tmp/config.py /tmp/main.py

echo "Container updated and restarted!"
EOF