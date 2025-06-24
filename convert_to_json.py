#!/usr/bin/env python3
"""
Convert all exported chat files to a single demo_chats.json
"""
import json
import os

demo_dir = "/mnt/c/eaglegpt/demo"
output_file = "/mnt/c/eaglegpt/demo_chats.json"

all_demo_chats = []

# Get all JSON files
json_files = sorted([f for f in os.listdir(demo_dir) if f.endswith('.json')])

for i, filename in enumerate(json_files):
    filepath = os.path.join(demo_dir, filename)
    
    try:
        with open(filepath, 'r', encoding='utf-8') as f:
            chat_data = json.load(f)
        
        # Extract the chat (exports are arrays with one item)
        original_chat = chat_data[0]
        
        # Create demo format with new ID
        demo_chat = {
            "id": f"demo_chat_{i + 1}",
            "title": original_chat["title"],
            "created_at": original_chat.get("created_at", 1750661687),
            "updated_at": original_chat.get("updated_at", 1750661687),
            "chat": original_chat["chat"],
            "meta": original_chat.get("meta", {"tags": []}),
            "pinned": original_chat.get("pinned", False),
            "archived": original_chat.get("archived", False),
            "share_id": None,
            "folder_id": None
        }
        
        all_demo_chats.append(demo_chat)
        print(f"Added: {demo_chat['title']}")
        
    except Exception as e:
        print(f"Error processing {filename}: {e}")

# Write all chats to single JSON file
with open(output_file, 'w', encoding='utf-8') as f:
    json.dump(all_demo_chats, f, indent=2, ensure_ascii=False)

print(f"\nWrote {len(all_demo_chats)} demo chats to {output_file}")