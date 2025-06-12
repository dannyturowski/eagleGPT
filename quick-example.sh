#!/bin/bash

# Quick Example: Deploy a test application to the private registry

echo "Creating test application..."
mkdir -p /tmp/registry-test
cd /tmp/registry-test

# Create a simple HTML file
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Private Registry Test</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 50px; }
        .container { max-width: 600px; margin: 0 auto; text-align: center; }
        h1 { color: #2ecc71; }
        .info { background: #f0f0f0; padding: 20px; border-radius: 10px; margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎉 Success!</h1>
        <div class="info">
            <h2>Private Docker Registry Working</h2>
            <p>This application was pushed to your private registry at 95.217.152.30:5000</p>
            <p>Time: <span id="time"></span></p>
        </div>
    </div>
    <script>
        document.getElementById('time').textContent = new Date().toLocaleString();
    </script>
</body>
</html>
EOF

# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM nginx:alpine
COPY index.html /usr/share/nginx/html/
EXPOSE 80
EOF

echo "Building Docker image..."
docker build -t registry-test:latest .

echo "Tagging for private registry..."
docker tag registry-test:latest 95.217.152.30:5000/registry-test:latest

echo "Pushing to registry..."
docker push 95.217.152.30:5000/registry-test:latest

echo "Deploying on server..."
docker --context hel1 pull localhost:5000/registry-test:latest
docker --context hel1 run -d -p 8082:80 --name registry-test localhost:5000/registry-test:latest

echo ""
echo "✅ Deployment complete!"
echo "🌐 Access your test app at: http://95.217.152.30:8082"
echo ""
echo "To check the registry contents:"
echo "curl http://95.217.152.30:5000/v2/_catalog"