#!/usr/bin/env python3
"""
Import exported OpenWebUI chat JSON files to demo chat format.
Preserves all original content exactly as is.
"""
import json
import os
import time

def convert_chat_to_demo_format(chat_data, demo_id):
    """Convert an exported chat to demo format, preserving all content."""
    
    # Extract the original chat (exports are arrays with one item)
    original_chat = chat_data[0]
    
    # Get the history messages
    original_history = original_chat["chat"]["history"]["messages"]
    
    # Convert the messages to demo format
    demo_messages = {}
    
    for msg_id, msg in original_history.items():
        demo_msg = {
            "id": msg_id,
            "role": msg["role"],
            "content": msg["content"],
            "timestamp": msg.get("timestamp", int(time.time()) - 86400),
        }
        
        if msg.get("parentId"):
            demo_msg["parentId"] = msg["parentId"]
        else:
            demo_msg["parentId"] = None
            
        if msg.get("childrenIds"):
            demo_msg["childrenIds"] = msg["childrenIds"]
        else:
            demo_msg["childrenIds"] = []
        
        if msg["role"] == "assistant":
            demo_msg["model"] = msg.get("model", "gpt-4")
            
        demo_messages[msg_id] = demo_msg
    
    # Create the demo chat structure
    demo_chat = {
        "id": demo_id,
        "title": original_chat["title"],
        "created_at": original_chat.get("created_at", int(time.time()) - 86400 * 7),
        "updated_at": original_chat.get("updated_at", int(time.time()) - 86400),
        "chat": {
            "history": {
                "currentId": original_chat["chat"]["history"]["currentId"],
                "messages": demo_messages
            }
        },
        "meta": {
            "tags": original_chat.get("meta", {}).get("tags", [])
        },
        "pinned": original_chat.get("pinned", False),
        "archived": original_chat.get("archived", False),
        "share_id": None,
        "folder_id": None
    }
    
    return demo_chat

def main():
    """Import all demo chat files."""
    demo_dir = "/mnt/c/eaglegpt/demo"
    
    # Get all JSON files
    json_files = sorted([f for f in os.listdir(demo_dir) if f.endswith('.json')])
    
    print("# Add these to the DEMO_CHATS list in demo_data.py:\n")
    
    for i, filename in enumerate(json_files):
        filepath = os.path.join(demo_dir, filename)
        
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                chat_data = json.load(f)
            
            demo_id = f"demo_chat_{i + 6}"  # Start from 6 since we have 5 already
            
            demo_chat = convert_chat_to_demo_format(chat_data, demo_id)
            
            # Print as Python dict format
            print(f"    {json.dumps(demo_chat, indent=4, ensure_ascii=False)},")
            print()  # Empty line between chats
            
        except Exception as e:
            print(f"# Error converting {filename}: {e}")

if __name__ == "__main__":
    main()