#!/bin/bash

echo "Building frontend for EagleGPT..."

# Clean previous builds
rm -rf build/

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm ci
fi

# Build with increased memory
echo "Building frontend..."
export NODE_OPTIONS="--max-old-space-size=8192"
npm run build

if [ $? -eq 0 ]; then
    echo "Build successful! Creating deployment archive..."
    
    # Create a tarball of the build directory
    tar -czf frontend-build.tar.gz build/
    
    # Copy to server
    echo "Copying to server..."
    scp frontend-build.tar.gz root@95.217.152.30:/tmp/
    
    # Deploy on server
    echo "Deploying on server..."
    ssh root@95.217.152.30 << 'EOF'
# Extract into container
cd /tmp
tar -xzf frontend-build.tar.gz

# Copy build files to container
docker cp build eaglegpt:/app/

# Clean up
rm -rf build frontend-build.tar.gz

# Restart container to apply changes
docker restart eaglegpt

echo "Frontend deployed!"
EOF
    
    # Clean up local files
    rm -f frontend-build.tar.gz
    
    echo "Deployment complete!"
else
    echo "Build failed!"
    exit 1
fi