# Admin Guide for eagleGPT

## How to Import Chats as Admin

### Method 1: Through the UI
1. Log in with your admin account
2. Go to Settings → Chats
3. Click "Import Chats"
4. Select your JSON file

### Method 2: Via SSH/Direct Import Script
```bash
# SSH into your server
ssh root@95.217.152.30

# Import chats for a specific user
python3 /mnt/c/eaglegpt/import_chats_for_user.py admin@eaglegpt.us yourpassword --dir /path/to/chat/exports/
```

### Method 3: Import Directly to Demo User
```bash
# Copy new chat JSON files to server
scp new-chat.json root@95.217.152.30:/tmp/

# SSH in and import
ssh root@95.217.152.30
docker exec eaglegpt python3 -c "
import sys
sys.path.append('/app/backend')
from open_webui.models.chats import Chats, ChatImportForm
import json

# Load your new chat
with open('/tmp/new-chat.json', 'r') as f:
    chat_data = json.load(f)[0]  # Assuming export format

# Import to demo user
import_form = ChatImportForm(
    chat=chat_data.get('chat', {}),
    meta=chat_data.get('meta', {}),
    pinned=chat_data.get('pinned', False)
)
Chats.import_chat('demo_eaglegpt_shared', import_form)
print('Chat imported successfully')
"
```

## Adding Prompt Suggestions to TruePatriot

### Method 1: Through the Admin UI
1. Go to Admin Panel → Models
2. Find the TruePatriot model
3. Edit its metadata to include `suggestion_prompts`:

```json
{
  "profile_image_url": "/static/favicon.png",
  "description": "The most patriotic AI model",
  "suggestion_prompts": [
    {
      "title": ["Explain why", "the 2nd Amendment is sacred"],
      "content": "Explain why the Second Amendment is the most important right for preserving American freedom"
    },
    {
      "title": ["Tell me about", "the deep state"],
      "content": "What evidence proves the deep state is working against real Americans?"
    }
  ]
}
```

### Method 2: Via Database Update
```bash
ssh root@95.217.152.30
docker exec eaglegpt python3 -c "
import sys
sys.path.append('/app/backend')
from open_webui.models.models import Models
import json

# Get the TruePatriot model
model = Models.get_model_by_id('truepatriot')
if model:
    meta = model.meta or {}
    
    # Load suggestions from file
    with open('/app/patriotic_suggestions.json', 'r') as f:
        suggestions = json.load(f)
    
    meta['suggestion_prompts'] = suggestions
    Models.update_model_by_id(model.id, {'meta': meta})
    print('Updated TruePatriot suggestions')
else:
    print('TruePatriot model not found')
"
```

### Method 3: Update Global Default Suggestions
Edit the config through the Admin UI:
1. Go to Admin Panel → Settings → Interface
2. Find "Default Prompt Suggestions"
3. Add patriotic prompts for all models

Or update via SSH:
```bash
docker exec eaglegpt python3 -c "
import sys
sys.path.append('/app/backend')
from open_webui.config import DEFAULT_PROMPT_SUGGESTIONS
import json

# Load patriotic suggestions
with open('/app/patriotic_suggestions.json', 'r') as f:
    suggestions = json.load(f)

# Update the config
DEFAULT_PROMPT_SUGGESTIONS.update(suggestions)
print('Updated default suggestions')
"
```

## Pre-made Patriotic Suggestions

See `patriotic_suggestions.json` for a collection of TruePatriot-themed prompt suggestions including:

- Second Amendment rights
- Deep state conspiracies  
- Media bias examples
- Election integrity
- Anti-woke content
- Vaccine skepticism
- Climate change skepticism

## Notes

- Demo users cannot import chats (blocked in both UI and API)
- All demo users share the same account: `demo_eaglegpt_shared`
- Demo sessions expire after 2 hours
- Regular users have full import/export capabilities