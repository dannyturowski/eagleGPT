#!/usr/bin/env python3
"""
Prepare demo chats for import by converting them to OpenWebUI's expected format.
This creates individual JSON files that can be imported using the UI or API.
"""
import json
import os
from pathlib import Path

def convert_demo_chat_to_import_format(demo_chat):
    """Convert a demo chat to the format expected by OpenWebUI's import."""
    # Create the import format
    import_chat = {
        "id": demo_chat["id"],
        "user_id": "",  # Will be set during import
        "title": demo_chat["title"],
        "chat": demo_chat["chat"],
        "created_at": demo_chat["created_at"],
        "updated_at": demo_chat["updated_at"],
        "share_id": demo_chat.get("share_id"),
        "archived": demo_chat.get("archived", False),
        "pinned": demo_chat.get("pinned", False),
        "meta": demo_chat.get("meta", {}),
        "folder_id": demo_chat.get("folder_id")
    }
    
    # Ensure the chat has the required structure
    if "id" not in import_chat["chat"]:
        import_chat["chat"]["id"] = ""
    if "title" not in import_chat["chat"]:
        import_chat["chat"]["title"] = demo_chat["title"]
    if "models" not in import_chat["chat"]:
        import_chat["chat"]["models"] = ["gpt-4"]  # Default model
    if "params" not in import_chat["chat"]:
        import_chat["chat"]["params"] = {}
        
    return import_chat

def main():
    """Convert demo chats to importable format."""
    # Read the demo chats
    demo_chats_file = "/mnt/c/eaglegpt/demo_chats.json"
    output_dir = "/mnt/c/eaglegpt/import_ready_chats"
    
    # Create output directory
    Path(output_dir).mkdir(parents=True, exist_ok=True)
    
    try:
        with open(demo_chats_file, 'r', encoding='utf-8') as f:
            demo_chats = json.load(f)
        
        print(f"Found {len(demo_chats)} demo chats to convert")
        
        # Convert each chat
        for i, demo_chat in enumerate(demo_chats):
            # Convert to import format
            import_chat = convert_demo_chat_to_import_format(demo_chat)
            
            # Save as individual file (OpenWebUI expects array format)
            output_file = os.path.join(output_dir, f"chat_{i+1:02d}_{demo_chat['id']}.json")
            
            with open(output_file, 'w', encoding='utf-8') as f:
                # Save as array with single chat (OpenWebUI's export format)
                json.dump([import_chat], f, indent=2, ensure_ascii=False)
            
            print(f"✓ Created {output_file}")
        
        print(f"\nSuccessfully converted {len(demo_chats)} chats!")
        print(f"Files saved to: {output_dir}")
        print("\nTo import these chats:")
        print("1. Using the UI: Go to Settings > Chats > Import Chats and select the files")
        print("2. Using the script: python import_chats_for_user.py <username> <password> --dir", output_dir)
        
    except Exception as e:
        print(f"Error: {e}")
        return 1
    
    return 0

if __name__ == "__main__":
    exit(main())