#!/usr/bin/env python3
"""
Import chat JSON files for a specific user using OpenWebUI's import API.
This uses the existing import functionality to properly populate a user's chat list.
"""
import json
import sys
import os
import requests
from typing import List, Dict, Any

# Configuration
WEBUI_API_BASE_URL = os.getenv("WEBUI_API_BASE_URL", "http://localhost:8080/api/v1")

def import_chat_file(token: str, chat_file_path: str) -> bool:
    """Import a single chat file for a user."""
    try:
        # Read the chat file
        with open(chat_file_path, 'r', encoding='utf-8') as f:
            chat_data = json.load(f)
        
        # Handle both single chat and array formats
        if isinstance(chat_data, list):
            # If it's an array, process each chat
            for chat in chat_data:
                success = import_single_chat(token, chat)
                if not success:
                    return False
        else:
            # Single chat object
            success = import_single_chat(token, chat_data)
            if not success:
                return False
                
        return True
        
    except Exception as e:
        print(f"Error importing {chat_file_path}: {e}")
        return False

def import_single_chat(token: str, chat: Dict[str, Any]) -> bool:
    """Import a single chat using the API."""
    try:
        # Prepare the import data
        import_data = {
            "chat": chat.get("chat", chat),  # Handle both wrapped and unwrapped formats
            "meta": chat.get("meta", {}),
            "pinned": chat.get("pinned", False),
            "folder_id": chat.get("folder_id", None)
        }
        
        # Make the API request
        response = requests.post(
            f"{WEBUI_API_BASE_URL}/chats/import",
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json"
            },
            json=import_data
        )
        
        if response.status_code == 200:
            result = response.json()
            print(f"✓ Imported chat: {result.get('title', 'Untitled')}")
            return True
        else:
            print(f"✗ Failed to import chat: {response.status_code} - {response.text}")
            return False
            
    except Exception as e:
        print(f"Error importing chat: {e}")
        return False

def get_user_token(username: str, password: str) -> str:
    """Login and get user token."""
    try:
        response = requests.post(
            f"{WEBUI_API_BASE_URL}/auths/signin",
            json={
                "email": username,
                "password": password
            }
        )
        
        if response.status_code == 200:
            data = response.json()
            return data.get("token")
        else:
            print(f"Login failed: {response.status_code} - {response.text}")
            return None
            
    except Exception as e:
        print(f"Error during login: {e}")
        return None

def main():
    """Main function to import chats."""
    if len(sys.argv) < 3:
        print("Usage: python import_chats_for_user.py <username> <password> [chat_file1.json] [chat_file2.json] ...")
        print("       python import_chats_for_user.py <username> <password> --dir <directory>")
        sys.exit(1)
    
    username = sys.argv[1]
    password = sys.argv[2]
    
    # Login to get token
    print(f"Logging in as {username}...")
    token = get_user_token(username, password)
    
    if not token:
        print("Failed to login!")
        sys.exit(1)
    
    print("Login successful!")
    
    # Determine files to import
    chat_files = []
    
    if len(sys.argv) > 3 and sys.argv[3] == "--dir":
        # Import all JSON files from directory
        if len(sys.argv) < 5:
            print("Please specify a directory after --dir")
            sys.exit(1)
            
        directory = sys.argv[4]
        if os.path.isdir(directory):
            chat_files = [
                os.path.join(directory, f) 
                for f in os.listdir(directory) 
                if f.endswith('.json')
            ]
            chat_files.sort()
        else:
            print(f"Directory not found: {directory}")
            sys.exit(1)
    else:
        # Import specific files
        chat_files = sys.argv[3:]
    
    if not chat_files:
        print("No chat files specified!")
        sys.exit(1)
    
    # Import each file
    print(f"\nImporting {len(chat_files)} chat file(s)...")
    success_count = 0
    
    for chat_file in chat_files:
        if os.path.exists(chat_file):
            if import_chat_file(token, chat_file):
                success_count += 1
        else:
            print(f"File not found: {chat_file}")
    
    print(f"\nImport complete! Successfully imported {success_count}/{len(chat_files)} files.")

if __name__ == "__main__":
    main()