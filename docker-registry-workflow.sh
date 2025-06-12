#!/bin/bash

# Docker Registry Workflow Script
# Server: 95.217.152.30 (hel1 context)
# Registry Port: 5000

# Configuration
REGISTRY_HOST="95.217.152.30:5000"
SERVER_CONTEXT="hel1"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Docker Registry Workflow${NC}"
echo "========================="
echo ""

# Function to print section headers
print_section() {
    echo -e "\n${YELLOW}$1${NC}"
    echo "----------------------------------------"
}

# 1. Build Docker Image Locally
print_section "1. BUILD IMAGE LOCALLY"
echo "Example: Building a simple nginx-based image"
echo ""
echo "# Create a Dockerfile (example):"
echo "cat > Dockerfile << EOF"
echo "FROM nginx:alpine"
echo "COPY index.html /usr/share/nginx/html/"
echo "EXPOSE 80"
echo "EOF"
echo ""
echo "# Build the image:"
echo "docker build -t myapp:latest ."
echo ""
echo "# For specific platform (if needed):"
echo "docker build --platform linux/amd64 -t myapp:latest ."

# 2. Tag Image for Registry
print_section "2. TAG IMAGE FOR REGISTRY"
echo "# Tag your image for the private registry:"
echo "docker tag myapp:latest ${REGISTRY_HOST}/myapp:latest"
echo ""
echo "# You can also tag with version:"
echo "docker tag myapp:latest ${REGISTRY_HOST}/myapp:v1.0"

# 3. Push to Registry
print_section "3. PUSH TO REGISTRY"
echo "# Push the image to the registry:"
echo "docker push ${REGISTRY_HOST}/myapp:latest"
echo ""
echo "# Push specific version:"
echo "docker push ${REGISTRY_HOST}/myapp:v1.0"

# 4. Pull and Run on Server
print_section "4. PULL AND RUN ON SERVER"
echo "# Option A: Using docker context from local machine:"
echo "docker --context ${SERVER_CONTEXT} pull localhost:5000/myapp:latest"
echo "docker --context ${SERVER_CONTEXT} run -d -p 8080:80 --name myapp localhost:5000/myapp:latest"
echo ""
echo "# Option B: SSH to server and run:"
echo "ssh root@95.217.152.30"
echo "docker pull localhost:5000/myapp:latest"
echo "docker run -d -p 8080:80 --name myapp localhost:5000/myapp:latest"

# 5. Registry Management Commands
print_section "5. USEFUL REGISTRY COMMANDS"
echo "# List all repositories in registry:"
echo "curl http://${REGISTRY_HOST}/v2/_catalog"
echo ""
echo "# List tags for a specific image:"
echo "curl http://${REGISTRY_HOST}/v2/myapp/tags/list"
echo ""
echo "# Check registry from server:"
echo "docker --context ${SERVER_CONTEXT} exec registry registry garbage-collect /etc/docker/registry/config.yml"

# 6. Complete Example
print_section "6. COMPLETE EXAMPLE"
echo "# Here's a complete example workflow:"
echo ""
echo "# 1. Create a simple test app"
echo "mkdir -p test-app && cd test-app"
echo ""
echo "# 2. Create index.html"
echo "echo '<h1>Hello from Private Registry!</h1>' > index.html"
echo ""
echo "# 3. Create Dockerfile"
echo "cat > Dockerfile << 'EOF'"
echo "FROM nginx:alpine"
echo "COPY index.html /usr/share/nginx/html/"
echo "EXPOSE 80"
echo "EOF"
echo ""
echo "# 4. Build and push"
echo "docker build -t test-app:latest ."
echo "docker tag test-app:latest ${REGISTRY_HOST}/test-app:latest"
echo "docker push ${REGISTRY_HOST}/test-app:latest"
echo ""
echo "# 5. Deploy on server"
echo "docker --context ${SERVER_CONTEXT} pull localhost:5000/test-app:latest"
echo "docker --context ${SERVER_CONTEXT} run -d -p 8081:80 --name test-app localhost:5000/test-app:latest"
echo ""
echo "# 6. Test"
echo "curl http://95.217.152.30:8081"

# 7. Security Considerations
print_section "7. SECURITY NOTES"
echo -e "${RED}WARNING:${NC} This registry is running over HTTP (not HTTPS)!"
echo "For production use, consider:"
echo "- Setting up TLS/SSL certificates"
echo "- Using authentication"
echo "- Implementing access controls"
echo ""
echo "To add basic authentication:"
echo "docker --context ${SERVER_CONTEXT} run --rm --entrypoint htpasswd registry:2 -Bbn myuser mypassword > htpasswd"
echo "Then restart registry with auth enabled."

# 8. Troubleshooting
print_section "8. TROUBLESHOOTING"
echo "If you get 'http: server gave HTTP response to HTTPS client':"
echo "Add this to your Docker daemon config (not recommended for production):"
echo ""
echo "# On local machine: /etc/docker/daemon.json"
echo "{"
echo '  "insecure-registries": ["95.217.152.30:5000"]'
echo "}"
echo ""
echo "Then restart Docker: sudo systemctl restart docker"

echo -e "\n${GREEN}Script generated successfully!${NC}"
echo "Registry is running at: http://${REGISTRY_HOST}"