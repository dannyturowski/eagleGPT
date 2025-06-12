#!/usr/bin/env python3
"""
Simple webhook server for automated deployments from GitHub
Run this on your server to listen for deployment webhooks
"""

import os
import json
import subprocess
import hmac
import hashlib
from http.server import HTTPServer, BaseHTTPRequestHandler

# Configuration
WEBHOOK_TOKEN = os.environ.get('WEBHOOK_TOKEN', 'your-secret-token-here')
WEBHOOK_PORT = int(os.environ.get('WEBHOOK_PORT', '8888'))
GHCR_IMAGE = os.environ.get('GHCR_IMAGE', 'ghcr.io/YOUR_USERNAME/eaglegpt:latest')

class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        # Verify authorization
        auth_header = self.headers.get('Authorization')
        if not auth_header or not auth_header.startswith('Bearer '):
            self.send_error(401)
            return
        
        token = auth_header.replace('Bearer ', '')
        if token != WEBHOOK_TOKEN:
            self.send_error(403)
            return
        
        # Read payload
        content_length = int(self.headers['Content-Length'])
        payload = self.rfile.read(content_length)
        
        try:
            data = json.loads(payload)
            image = data.get('image', GHCR_IMAGE)
            
            # Deploy
            print(f"Deploying {image}...")
            result = subprocess.run([
                'bash', '-c', f'''
                docker pull {image} && \
                docker stop eaglegpt 2>/dev/null || true && \
                docker rm eaglegpt 2>/dev/null || true && \
                docker run -d \
                    --name eaglegpt \
                    --restart unless-stopped \
                    -p 3000:8080 \
                    -v /opt/openwebui/data:/app/backend/data \
                    -v /opt/openwebui/backup:/app/backup \
                    -e WEBUI_NAME="eagleGPT" \
                    -e WEBUI_URL="http://95.217.152.30:3000" \
                    -e WEBUI_SECRET_KEY="$(openssl rand -hex 32)" \
                    -e ENABLE_SIGNUP="true" \
                    {image}
                '''
            ], capture_output=True, text=True)
            
            if result.returncode == 0:
                self.send_response(200)
                self.send_header('Content-type', 'application/json')
                self.end_headers()
                self.wfile.write(json.dumps({'status': 'success'}).encode())
            else:
                self.send_error(500, result.stderr)
                
        except Exception as e:
            self.send_error(500, str(e))
    
    def log_message(self, format, *args):
        print(f"{self.address_string()} - {format % args}")

if __name__ == '__main__':
    print(f"Starting webhook server on port {WEBHOOK_PORT}")
    print(f"Will deploy image: {GHCR_IMAGE}")
    server = HTTPServer(('0.0.0.0', WEBHOOK_PORT), WebhookHandler)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\nShutting down...")
        server.shutdown()