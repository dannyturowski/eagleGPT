#!/usr/bin/env python3
"""
Test script to verify demo mode configuration in the API
"""

import requests
import json

BASE_URL = "http://localhost:8080"  # Adjust if your backend runs on a different port

def test_config_endpoint():
    """Test the /api/config endpoint to check if enable_demo_mode is exposed"""
    print("\n=== Testing /api/config endpoint ===")
    try:
        response = requests.get(f"{BASE_URL}/api/config")
        if response.status_code == 200:
            data = response.json()
            print(f"Status: {response.status_code}")
            print(f"Response data (features section):")
            features = data.get('features', {})
            print(json.dumps(features, indent=2))
            
            # Check for enable_demo_mode
            if 'enable_demo_mode' in features:
                print(f"\n✓ enable_demo_mode found: {features['enable_demo_mode']}")
            else:
                print("\n✗ enable_demo_mode NOT found in features")
        else:
            print(f"Error: Status code {response.status_code}")
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error connecting to API: {e}")

def test_demo_endpoint():
    """Test the /auths/demo endpoint"""
    print("\n\n=== Testing /auths/demo endpoint ===")
    try:
        response = requests.post(f"{BASE_URL}/auths/demo")
        print(f"Status: {response.status_code}")
        if response.status_code == 200:
            data = response.json()
            print(f"Demo session created successfully!")
            print(f"User ID: {data.get('id')}")
            print(f"User Name: {data.get('name')}")
            print(f"Token (first 20 chars): {data.get('token', '')[:20]}...")
        elif response.status_code == 403:
            print(f"Demo mode is disabled: {response.json().get('detail')}")
        else:
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    print("Demo Mode API Test")
    print("==================")
    print(f"Testing backend at: {BASE_URL}")
    
    test_config_endpoint()
    test_demo_endpoint()
    
    print("\n\n=== Summary ===")
    print("Frontend should check for demo mode availability by:")
    print("1. Fetching /api/config")
    print("2. Checking response.features.enable_demo_mode")
    print("3. If true, show 'Try Demo' button that POSTs to /auths/demo")
    print("4. Handle the response token/user session from /auths/demo")