# OpenWebUI Chat Import Guide

This guide explains how to pre-populate demo user chats using OpenWebUI's existing import functionality.

## Overview

OpenWebUI has built-in chat import/export functionality that can be leveraged to pre-populate user accounts with demo chats. The system uses a JSON format for chat data that preserves the complete chat history including messages, timestamps, and metadata.

## Chat Format

OpenWebUI exports chats as JSON arrays containing chat objects. Each chat has this structure:

```json
[
  {
    "id": "unique-chat-id",
    "user_id": "user-id",
    "title": "Chat Title",
    "chat": {
      "id": "",
      "title": "Chat Title",
      "models": ["model-name"],
      "params": {},
      "history": {
        "currentId": "last-message-id",
        "messages": {
          "message-id": {
            "id": "message-id",
            "parentId": null,
            "childrenIds": ["next-message-id"],
            "role": "user",
            "content": "User message",
            "timestamp": 1234567890
          }
        }
      }
    },
    "created_at": 1234567890,
    "updated_at": 1234567890,
    "share_id": null,
    "archived": false,
    "pinned": false,
    "meta": {
      "tags": []
    },
    "folder_id": null
  }
]
```

## Import Methods

### Method 1: UI Import (Manual)

1. Login to OpenWebUI as the target user
2. Go to Settings → Chats
3. Click "Import Chats"
4. Select the JSON file(s) to import
5. Chats will be added to the user's chat list

### Method 2: API Import (Programmatic)

Use the `/api/v1/chats/import` endpoint:

```python
import requests

# Login to get token
response = requests.post(
    "http://localhost:8080/api/v1/auths/signin",
    json={"email": "user@example.com", "password": "password"}
)
token = response.json()["token"]

# Import chat
with open("chat.json", "r") as f:
    chat_data = json.load(f)[0]  # Get first chat from array

response = requests.post(
    "http://localhost:8080/api/v1/chats/import",
    headers={"Authorization": f"Bearer {token}"},
    json={
        "chat": chat_data["chat"],
        "meta": chat_data.get("meta", {}),
        "pinned": chat_data.get("pinned", False),
        "folder_id": chat_data.get("folder_id", None)
    }
)
```

### Method 3: Bulk Import Script

Two scripts are provided for bulk operations:

1. **prepare_import_chats.py** - Converts demo_chats.json to individual importable files
2. **import_chats_for_user.py** - Imports multiple chat files for a specific user

Usage:
```bash
# Prepare chats for import
python prepare_import_chats.py

# Import all prepared chats for a user
python import_chats_for_user.py username password --dir import_ready_chats/

# Or import specific files
python import_chats_for_user.py username password chat1.json chat2.json
```

## Creating Demo Chats

To create new demo chats:

1. Use OpenWebUI normally to have conversations
2. Export the chats (Settings → Chats → Export)
3. Edit the exported JSON to:
   - Remove user-specific IDs
   - Adjust timestamps if needed
   - Add appropriate titles and tags
4. Save as individual JSON files

## Integration Points

The least invasive integration points are:

1. **Frontend Import**: The existing import functionality in `/src/lib/components/chat/Settings/Chats.svelte`
2. **API Endpoint**: The `/api/v1/chats/import` endpoint in `/backend/open_webui/routers/chats.py`
3. **Chat Creation**: The `createNewChat` and `importChat` functions in `/src/lib/apis/chats/index.ts`

## Best Practices

1. **Preserve Message IDs**: Keep the message ID structure intact to maintain conversation flow
2. **Use Realistic Timestamps**: Set timestamps to make chats appear naturally aged
3. **Test Import**: Always test importing chats on a development instance first
4. **Batch Operations**: Import multiple chats at once to improve performance
5. **Error Handling**: The import process will skip invalid chats rather than failing entirely

## Demo User Consideration

For the existing demo user system that loads chats from `demo_chats.json`, you can:

1. Continue using the in-memory approach for true demo/preview users
2. Use the import functionality for registered users who need pre-populated content
3. Provide a "Load Sample Chats" button that triggers the import process

This approach leverages OpenWebUI's existing functionality without requiring custom modifications to the core chat system.