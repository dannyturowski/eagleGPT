#!/usr/bin/env python3
"""Test pipeline API endpoints to understand OpenWebUI's expected format"""

import requests
import json

# Test endpoints
base_url = "http://localhost:9099"
api_key = "sk-eaglegpt-pipeline-key"
headers = {"Authorization": f"Bearer {api_key}"}

print("Testing Pipeline API Endpoints:")
print("=" * 50)

# Test 1: Root endpoint
try:
    response = requests.get(f"{base_url}/", headers=headers)
    print(f"GET /: {response.status_code}")
    print(f"Response: {response.text}\n")
except Exception as e:
    print(f"GET / failed: {e}\n")

# Test 2: /v1/models endpoint
try:
    response = requests.get(f"{base_url}/v1/models", headers=headers)
    print(f"GET /v1/models: {response.status_code}")
    print(f"Response: {json.dumps(response.json(), indent=2)}\n")
except Exception as e:
    print(f"GET /v1/models failed: {e}\n")

# Test 3: /models endpoint (alternative)
try:
    response = requests.get(f"{base_url}/models", headers=headers)
    print(f"GET /models: {response.status_code}")
    print(f"Response: {response.text}\n")
except Exception as e:
    print(f"GET /models failed: {e}\n")

# Test 4: /api/models endpoint
try:
    response = requests.get(f"{base_url}/api/models", headers=headers)
    print(f"GET /api/models: {response.status_code}")
    print(f"Response: {response.text}\n")
except Exception as e:
    print(f"GET /api/models failed: {e}\n")

# Test 5: OpenAPI schema
try:
    response = requests.get(f"{base_url}/openapi.json", headers=headers)
    print(f"GET /openapi.json: {response.status_code}")
    if response.status_code == 200:
        openapi = response.json()
        print(f"OpenAPI Title: {openapi.get('info', {}).get('title', 'N/A')}")
        print(f"OpenAPI Version: {openapi.get('info', {}).get('version', 'N/A')}")
        print(f"Available Paths: {list(openapi.get('paths', {}).keys())[:5]}...\n")
except Exception as e:
    print(f"GET /openapi.json failed: {e}\n")