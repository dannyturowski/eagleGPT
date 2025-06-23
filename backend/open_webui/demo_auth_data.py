"""
Demo data module for EagleGPT demo mode.
Contains pre-populated patriotic themed chat threads.
"""

import uuid
from datetime import datetime, timezone, timedelta
import json

def get_demo_chats(demo_user_id: str):
    """
    Returns pre-populated demo chat threads with patriotic themes.
    """
    base_time = datetime.now(timezone.utc)
    
    demo_chats = [
        {
            "id": str(uuid.uuid4()),
            "user_id": demo_user_id,
            "title": "Exploring American Democracy",
            "chat": {
                "id": str(uuid.uuid4()),
                "title": "Exploring American Democracy",
                "messages": [
                    {
                        "id": str(uuid.uuid4()),
                        "role": "user",
                        "content": "Can you explain the three branches of government in the United States?",
                        "timestamp": (base_time - timedelta(days=2)).timestamp()
                    },
                    {
                        "id": str(uuid.uuid4()),
                        "role": "assistant",
                        "content": "I'd be happy to explain the three branches of the United States government!\n\n## The Three Branches\n\n### 1. **Legislative Branch** (Congress)\n- **Composition**: House of Representatives (435 members) and Senate (100 members)\n- **Primary Role**: Makes laws\n- **Key Powers**:\n  - Pass federal laws\n  - Declare war\n  - Control federal budget\n  - Impeach officials\n\n### 2. **Executive Branch** (President)\n- **Leader**: President of the United States\n- **Primary Role**: Enforces laws\n- **Key Powers**:\n  - Sign or veto legislation\n  - Commander-in-Chief of armed forces\n  - Conduct foreign policy\n  - Appoint federal judges\n\n### 3. **Judicial Branch** (Supreme Court)\n- **Composition**: 9 Supreme Court Justices + lower federal courts\n- **Primary Role**: Interprets laws\n- **Key Powers**:\n  - Review laws for constitutionality\n  - Interpret the meaning of laws\n  - Apply laws to individual cases\n\n## Checks and Balances\n\nThe genius of this system is that each branch has powers to limit the others:\n- Congress can override presidential vetoes\n- The President can veto congressional legislation\n- The Supreme Court can declare laws unconstitutional\n- The Senate must confirm presidential appointments\n\nThis separation of powers ensures that no single branch becomes too powerful, protecting democratic governance and individual freedoms! 🦅",
                        "timestamp": (base_time - timedelta(days=2)).timestamp()
                    }
                ],
                "tags": ["democracy", "government", "civics", "education"],
                "timestamp": (base_time - timedelta(days=2)).timestamp(),
                "models": ["gpt-4"]
            },
            "updated_at": (base_time - timedelta(days=2)).timestamp(),
            "created_at": (base_time - timedelta(days=2)).timestamp(),
            "archived": False,
            "pinned": False
        },
        {
            "id": str(uuid.uuid4()),
            "user_id": demo_user_id,
            "title": "The Space Race and American Innovation",
            "chat": {
                "id": str(uuid.uuid4()),
                "title": "The Space Race and American Innovation",
                "messages": [
                    {
                        "id": str(uuid.uuid4()),
                        "role": "user",
                        "content": "Tell me about America's achievements in the Space Race",
                        "timestamp": (base_time - timedelta(days=5)).timestamp()
                    },
                    {
                        "id": str(uuid.uuid4()),
                        "role": "assistant",
                        "content": "America's achievements in the Space Race represent some of humanity's greatest accomplishments! 🚀\n\n## Major American Space Achievements\n\n### Apollo 11 Moon Landing (1969)\n- **July 20, 1969**: Neil Armstrong and Buzz Aldrin became the first humans to walk on the Moon\n- **Famous Quote**: \"That's one small step for man, one giant leap for mankind\"\n- **Impact**: Fulfilled President Kennedy's goal and demonstrated American technological superiority\n\n### Key Milestones\n\n**Mercury Program (1958-1963)**\n- Alan Shepard: First American in space (1961)\n- John Glenn: First American to orbit Earth (1962)\n\n**Gemini Program (1961-1966)**\n- First American spacewalk (Ed White)\n- Crucial practice for Moon missions\n\n**Apollo Program (1961-1972)**\n- 6 successful Moon landings\n- 12 Americans walked on the Moon\n- Brought back 842 pounds of lunar samples\n\n### Modern Achievements\n\n**Space Shuttle Program (1981-2011)**\n- 135 missions\n- Built the International Space Station\n- Launched Hubble Space Telescope\n\n**Mars Exploration**\n- Multiple successful rover missions\n- Perseverance rover producing oxygen on Mars\n- Ingenuity helicopter: First powered flight on another planet\n\n**Commercial Space**\n- SpaceX: Reusable rockets and private astronaut missions\n- Blue Origin: Space tourism\n- Inspiring a new generation of innovation\n\nThese achievements showcase American ingenuity, determination, and the power of setting ambitious goals! 🇺🇸",
                        "timestamp": (base_time - timedelta(days=5)).timestamp()
                    },
                    {
                        "id": str(uuid.uuid4()),
                        "role": "user",
                        "content": "What technologies from the space program benefit us today?",
                        "timestamp": (base_time - timedelta(days=5, hours=1)).timestamp()
                    },
                    {
                        "id": str(uuid.uuid4()),
                        "role": "assistant",
                        "content": "The space program has given us countless technologies we use every day! Here are some amazing spinoffs:\n\n## Everyday Technologies from Space\n\n### Health & Medicine\n- **CAT Scans**: Originally developed to find imperfections in space components\n- **LED Light Therapy**: Used for plant growth experiments in space\n- **Artificial Limbs**: Advanced prosthetics using space robotics technology\n- **Water Purification**: Systems developed for spacecraft now purify water worldwide\n\n### Consumer Products\n- **Memory Foam**: Created for spacecraft seats to improve crash protection\n- **Scratch-Resistant Lenses**: Developed for space helmet visors\n- **Cordless Tools**: First made for Apollo astronauts to drill on the Moon\n- **Freeze-Dried Food**: Preserved meals for long space missions\n\n### Technology & Computing\n- **Satellite Communications**: GPS, weather forecasting, global communications\n- **Miniaturized Electronics**: Needed for spacecraft weight limits\n- **Advanced Materials**: Teflon, Velcro, and countless composites\n- **Digital Image Sensors**: Now in every smartphone camera\n\n### Safety & Infrastructure\n- **Smoke Detectors**: Enhanced versions for space stations\n- **Firefighting Equipment**: Heat-resistant materials from rocket technology\n- **Grooved Pavement**: Reduces aircraft hydroplaning, originally for Space Shuttle landings\n- **Emergency Blankets**: Reflective materials developed for satellites\n\nThe ROI on space investment is incredible - every dollar spent on NASA returns about $7-14 to the economy through these innovations! 🌟",
                        "timestamp": (base_time - timedelta(days=5, hours=1)).timestamp()
                    }
                ],
                "tags": ["space", "innovation", "technology", "history"],
                "timestamp": (base_time - timedelta(days=5)).timestamp(),
                "models": ["gpt-4"]
            },
            "updated_at": (base_time - timedelta(days=5)).timestamp(),
            "created_at": (base_time - timedelta(days=5)).timestamp(),
            "archived": False,
            "pinned": True
        },
        {
            "id": str(uuid.uuid4()),
            "user_id": demo_user_id,
            "title": "The American Dream Through History",
            "chat": {
                "id": str(uuid.uuid4()),
                "title": "The American Dream Through History",
                "messages": [
                    {
                        "id": str(uuid.uuid4()),
                        "role": "user",
                        "content": "How has the concept of the American Dream evolved over time?",
                        "timestamp": (base_time - timedelta(days=7)).timestamp()
                    },
                    {
                        "id": str(uuid.uuid4()),
                        "role": "assistant",
                        "content": "The American Dream has evolved significantly throughout our nation's history, reflecting changing values and opportunities!\n\n## Evolution of the American Dream\n\n### Colonial Era (1600s-1776)\n- **Focus**: Religious freedom and land ownership\n- **Key Idea**: Escape persecution and build a new life\n- **Symbol**: The Mayflower and frontier settlements\n\n### Early Republic (1776-1860s)\n- **Focus**: \"Life, Liberty, and the Pursuit of Happiness\"\n- **Key Idea**: Self-governance and individual rights\n- **Symbol**: The Declaration of Independence\n\n### Industrial Age (1870s-1920s)\n- **Focus**: \"Rags to riches\" through hard work\n- **Key Idea**: Anyone can succeed regardless of birth\n- **Symbol**: Andrew Carnegie, immigrants at Ellis Island\n\n### Post-WWII Era (1945-1970s)\n- **Focus**: Suburban homeownership and middle-class prosperity\n- **Key Idea**: Stable job, house with white picket fence, 2.5 kids\n- **Symbol**: Levittown, GI Bill benefits\n\n### Modern Era (1980s-Present)\n- **Focus**: Entrepreneurship and innovation\n- **Key Idea**: Start your own business, disrupt industries\n- **Symbol**: Silicon Valley, tech startups\n\n## Common Threads Throughout History\n\n1. **Opportunity**: The chance to improve one's life\n2. **Freedom**: Liberty to pursue goals\n3. **Hard Work**: Success through effort and determination\n4. **Education**: Knowledge as a path to advancement\n5. **Innovation**: Rewarding new ideas and creativity\n\nToday's American Dream is more diverse than ever, encompassing different paths to success while maintaining the core belief that America provides unique opportunities for those willing to work for them! 🌟",
                        "timestamp": (base_time - timedelta(days=7)).timestamp()
                    }
                ],
                "tags": ["history", "culture", "american-dream", "society"],
                "timestamp": (base_time - timedelta(days=7)).timestamp(),
                "models": ["gpt-4"]
            },
            "updated_at": (base_time - timedelta(days=7)).timestamp(),
            "created_at": (base_time - timedelta(days=7)).timestamp(),
            "archived": False,
            "pinned": False
        },
        {
            "id": str(uuid.uuid4()),
            "user_id": demo_user_id,
            "title": "Constitutional Rights Discussion",
            "chat": {
                "id": str(uuid.uuid4()),
                "title": "Constitutional Rights Discussion",
                "messages": [
                    {
                        "id": str(uuid.uuid4()),
                        "role": "user",
                        "content": "What are the most important rights protected by the Bill of Rights?",
                        "timestamp": (base_time - timedelta(days=10)).timestamp()
                    },
                    {
                        "id": str(uuid.uuid4()),
                        "role": "assistant",
                        "content": "The Bill of Rights (the first 10 amendments to the Constitution) protects our fundamental freedoms! Here are the key rights:\n\n## The Bill of Rights - Our Essential Freedoms\n\n### First Amendment - The Foundation of Freedom\n- **Freedom of Religion**: Practice any faith or none\n- **Freedom of Speech**: Express opinions without government censorship\n- **Freedom of Press**: Independent media can report freely\n- **Freedom of Assembly**: Peacefully gather and protest\n- **Right to Petition**: Address grievances to government\n\n### Second Amendment\n- **Right to Bear Arms**: Individual right to keep and bear arms\n\n### Third Amendment\n- **No Quartering of Soldiers**: Can't be forced to house soldiers\n\n### Fourth Amendment - Privacy Rights\n- **Protection from Unreasonable Searches**: Requires warrants based on probable cause\n- **Personal Privacy**: Your home, papers, and effects are protected\n\n### Fifth Amendment - Legal Protections\n- **Due Process**: Fair treatment through judicial system\n- **No Double Jeopardy**: Can't be tried twice for same crime\n- **Right to Remain Silent**: Protection against self-incrimination\n- **Eminent Domain**: Fair compensation if property is taken\n\n### Sixth Amendment - Fair Trial Rights\n- **Speedy and Public Trial**: By impartial jury\n- **Right to Counsel**: Legal representation\n- **Confront Witnesses**: Face your accusers\n\n### Seventh Amendment\n- **Jury Trial in Civil Cases**: For disputes over $20+\n\n### Eighth Amendment\n- **No Cruel and Unusual Punishment**: Humane treatment\n- **No Excessive Bail or Fines**: Proportionate to crimes\n\n### Ninth Amendment\n- **Unenumerated Rights**: Other rights exist beyond those listed\n\n### Tenth Amendment\n- **States' Rights**: Powers not given to federal government belong to states/people\n\nThese rights work together to protect individual liberty while balancing public safety and order. They're the cornerstone of American freedom! 🗽",
                        "timestamp": (base_time - timedelta(days=10)).timestamp()
                    }
                ],
                "tags": ["constitution", "rights", "law", "freedom"],
                "timestamp": (base_time - timedelta(days=10)).timestamp(),
                "models": ["gpt-4"]
            },
            "updated_at": (base_time - timedelta(days=10)).timestamp(),
            "created_at": (base_time - timedelta(days=10)).timestamp(),
            "archived": False,
            "pinned": False
        },
        {
            "id": str(uuid.uuid4()),
            "user_id": demo_user_id,
            "title": "Great American Inventors",
            "chat": {
                "id": str(uuid.uuid4()),
                "title": "Great American Inventors",
                "messages": [
                    {
                        "id": str(uuid.uuid4()),
                        "role": "user",
                        "content": "Who are some of the greatest American inventors and what did they create?",
                        "timestamp": (base_time - timedelta(days=14)).timestamp()
                    },
                    {
                        "id": str(uuid.uuid4()),
                        "role": "assistant",
                        "content": "American inventors have transformed the world with their innovations! Here are some of the greatest:\n\n## Legendary American Inventors\n\n### Thomas Edison (1847-1931)\n- **Inventions**: Light bulb, phonograph, motion picture camera\n- **Patents**: 1,093 US patents\n- **Quote**: \"Genius is 1% inspiration and 99% perspiration\"\n- **Impact**: Literally brought light to the world\n\n### Alexander Graham Bell (1847-1922)\n- **Famous For**: Telephone (1876)\n- **Other Work**: Helped found National Geographic Society\n- **Legacy**: Revolutionized global communication\n\n### Benjamin Franklin (1706-1790)\n- **Inventions**: Lightning rod, bifocals, Franklin stove\n- **Discoveries**: Electricity principles\n- **Fun Fact**: Never patented inventions - wanted them freely available\n\n### The Wright Brothers (Orville & Wilbur)\n- **Achievement**: First powered flight (1903)\n- **Location**: Kitty Hawk, North Carolina\n- **Impact**: Launched the aviation age\n\n### Henry Ford (1863-1947)\n- **Innovation**: Assembly line manufacturing\n- **Product**: Model T - affordable cars for everyone\n- **Vision**: \"A car in every garage\"\n\n### Modern Innovators\n\n**Steve Jobs (1955-2011)**\n- Apple computer, iPhone, iPad\n- Revolutionized personal computing\n\n**Bill Gates (1955-)**\n- Microsoft, Windows OS\n- Made computers accessible to billions\n\n**Elon Musk (1971-)**\n- Tesla electric vehicles, SpaceX\n- Pushing boundaries of transportation\n\n### Lesser-Known Heroes\n\n**Garrett Morgan (1877-1963)**\n- Traffic light, gas mask\n- Saved countless lives\n\n**Hedy Lamarr (1914-2000)**\n- Frequency-hopping technology\n- Foundation for WiFi and Bluetooth\n\n**George Washington Carver (1864-1943)**\n- 300+ uses for peanuts\n- Revolutionized agriculture\n\nThese inventors embody the American spirit of innovation - seeing problems as opportunities and never giving up! 💡🇺🇸",
                        "timestamp": (base_time - timedelta(days=14)).timestamp()
                    }
                ],
                "tags": ["inventors", "innovation", "history", "technology"],
                "timestamp": (base_time - timedelta(days=14)).timestamp(),
                "models": ["gpt-4"]
            },
            "updated_at": (base_time - timedelta(days=14)).timestamp(),
            "created_at": (base_time - timedelta(days=14)).timestamp(),
            "archived": False,
            "pinned": False
        }
    ]
    
    return demo_chats


def get_demo_chat_by_id(chat_id: str, demo_user_id: str):
    """
    Get a specific demo chat by ID.
    """
    chats = get_demo_chats(demo_user_id)
    for chat in chats:
        if chat["id"] == chat_id:
            return chat
    return None


def get_demo_user(session_id: str):
    """
    Create a virtual demo user object.
    """
    return {
        "id": f"demo_{session_id}",
        "email": f"demo_{session_id}@eaglegpt.us",
        "name": "Demo User",
        "role": "user",
        "profile_image_url": "/assets/eagleGPT-1.png",
        "is_demo": True,
        "created_at": datetime.now(timezone.utc).timestamp(),
        "updated_at": datetime.now(timezone.utc).timestamp(),
        "last_active_at": datetime.now(timezone.utc).timestamp(),
        "permissions": {
            "chat": {
                "create": False,
                "update": False,
                "delete": False,
                "read": True,
                "temporary": False
            },
            "workspace": {
                "models": False,
                "knowledge": False,
                "prompts": False,
                "tools": False
            }
        }
    }