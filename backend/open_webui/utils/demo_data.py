"""
Demo data management for EagleGPT demo mode.
Provides pre-populated chat threads for demo users.
"""
import json
import time
import uuid
from typing import List, Dict, Any

# Demo chat threads with patriotic themes
DEMO_CHATS = [
    {
        "id": "demo_chat_1",
        "title": "The Birth of American Democracy",
        "created_at": int(time.time()) - 86400 * 7,  # 7 days ago
        "updated_at": int(time.time()) - 86400 * 7,
        "chat": {
            "history": {
                "currentId": "msg_3",
                "messages": {
                    "msg_1": {
                        "id": "msg_1",
                        "role": "user",
                        "content": "Tell me about the founding fathers and their vision for America",
                        "timestamp": int(time.time()) - 86400 * 7,
                    },
                    "msg_2": {
                        "id": "msg_2",
                        "role": "assistant",
                        "content": """The Founding Fathers of America were a remarkable group of individuals who laid the foundation for what would become the United States of America. Their vision was revolutionary for its time, centered on several key principles:

**Key Founding Fathers:**
- George Washington - The military leader and first President
- Thomas Jefferson - Primary author of the Declaration of Independence
- Benjamin Franklin - Diplomat, inventor, and philosopher
- John Adams - Advocate for independence and second President
- Alexander Hamilton - Architect of the American financial system
- James Madison - "Father of the Constitution"

**Their Core Vision:**

1. **Liberty and Individual Rights**: They believed in natural rights - life, liberty, and the pursuit of happiness - that government could not take away.

2. **Self-Governance**: The radical idea that people could govern themselves without kings or nobility.

3. **Separation of Powers**: They designed a system with checks and balances to prevent any one branch from becoming too powerful.

4. **Rule of Law**: The Constitution would be the supreme law, binding even those in power.

5. **Religious Freedom**: While many were religious, they established separation of church and state.

Their vision wasn't perfect - it initially excluded women, enslaved people, and those without property from full participation. However, they created a framework flexible enough to expand rights over time, leading to a more inclusive democracy.

The genius of their vision was creating a system that could evolve while maintaining its core principles of freedom and self-governance.""",
                        "timestamp": int(time.time()) - 86400 * 7 + 60,
                        "model": "gpt-4",
                    },
                    "msg_3": {
                        "id": "msg_3",
                        "role": "user",
                        "content": "What makes the American Constitution unique?",
                        "timestamp": int(time.time()) - 86400 * 7 + 120,
                    },
                    "msg_4": {
                        "id": "msg_4",
                        "role": "assistant",
                        "content": """The United States Constitution stands as one of history's most innovative and enduring governing documents. Here's what makes it truly unique:

**1. First Written Constitution**
The U.S. Constitution was the world's first written constitution for a modern nation-state, serving as a model for democracies worldwide.

**2. "We the People" - Popular Sovereignty**
Unlike previous governments deriving authority from monarchs or divine right, the Constitution begins with "We the People," establishing that government power comes from the citizens.

**3. Innovative Structure:**
- **Separation of Powers**: Three co-equal branches (Executive, Legislative, Judicial)
- **Checks and Balances**: Each branch can limit the others' powers
- **Federalism**: Power divided between federal and state governments

**4. Bill of Rights**
The first ten amendments guarantee fundamental freedoms:
- Freedom of speech, religion, press, and assembly
- Right to bear arms
- Protection against unreasonable searches
- Right to due process
- Right to trial by jury

**5. Amendment Process**
The Constitution can be changed, but it's intentionally difficult, requiring:
- 2/3 of both houses of Congress OR 2/3 of state legislatures to propose
- 3/4 of states to ratify

**6. Brevity and Flexibility**
At just 4,543 words (including signatures), it's remarkably concise, establishing principles rather than detailed laws, allowing interpretation for changing times.

**7. Longest-Serving Constitution**
At 235+ years old, it's the world's longest-surviving written charter of government.

**Impact**: The Constitution has inspired over 100 other nations' constitutions and remains a beacon of democratic governance, proving that self-rule under law is not only possible but can endure and thrive.""",
                        "timestamp": int(time.time()) - 86400 * 7 + 180,
                        "model": "gpt-4",
                    }
                }
            }
        },
        "meta": {
            "tags": ["history", "democracy", "constitution"]
        },
        "pinned": True,
        "archived": False,
        "share_id": None,
        "folder_id": None
    },
    {
        "id": "demo_chat_2",
        "title": "American Innovation and Space Exploration",
        "created_at": int(time.time()) - 86400 * 5,  # 5 days ago
        "updated_at": int(time.time()) - 86400 * 5,
        "chat": {
            "history": {
                "currentId": "msg_2",
                "messages": {
                    "msg_1": {
                        "id": "msg_1",
                        "role": "user",
                        "content": "How did America become a leader in space exploration?",
                        "timestamp": int(time.time()) - 86400 * 5,
                    },
                    "msg_2": {
                        "id": "msg_2",
                        "role": "assistant",
                        "content": """America's journey to space leadership is a story of determination, innovation, and the power of setting audacious goals. Here's how the United States became the world's premier spacefaring nation:

**The Space Race Begins (1957-1961)**
- Soviet Union launches Sputnik (1957), shocking America
- NASA created in 1958 to coordinate civilian space efforts
- Early setbacks motivated greater investment and focus

**Kennedy's Bold Vision (1961)**
President John F. Kennedy's famous speech to Congress:
> "I believe that this nation should commit itself to achieving the goal, before this decade is out, of landing a man on the Moon and returning him safely to the Earth."

**Key Factors in American Success:**

1. **Massive Investment**: The Apollo program cost $25 billion (1973 dollars), demonstrating national commitment

2. **Private-Public Partnership**: Thousands of companies contributed, from Boeing to IBM to Playtex (who made the spacesuits!)

3. **Educational Focus**: Emphasis on STEM education created a generation of scientists and engineers

4. **Open Society Advantage**: Unlike the secretive Soviet program, NASA's openness allowed for:
   - Public support and excitement
   - International collaboration
   - Rapid sharing of knowledge

5. **Risk-Taking Culture**: Willingness to push boundaries despite dangers

**Historic Achievements:**
- **Apollo 11 (1969)**: Neil Armstrong and Buzz Aldrin walk on the Moon
- **Space Shuttle Program (1981-2011)**: Reusable spacecraft revolutionizes access to space
- **International Space Station**: Leading international collaboration
- **Mars Rovers**: Multiple successful missions exploring the Red Planet
- **Commercial Space**: SpaceX, Blue Origin, and others continuing American innovation

**Modern Leadership:**
Today, America leads through:
- NASA's cutting-edge missions (James Webb Telescope, Artemis Moon program)
- Thriving commercial space industry
- International partnerships
- Inspiring new generations to reach for the stars

The American space program exemplifies how democracy, free enterprise, and human ambition can achieve the impossible! 🚀🇺🇸""",
                        "timestamp": int(time.time()) - 86400 * 5 + 60,
                        "model": "gpt-4",
                    }
                }
            }
        },
        "meta": {
            "tags": ["space", "innovation", "technology"]
        },
        "pinned": False,
        "archived": False,
        "share_id": None,
        "folder_id": None
    },
    {
        "id": "demo_chat_3",
        "title": "The American Dream: Past and Present",
        "created_at": int(time.time()) - 86400 * 3,  # 3 days ago
        "updated_at": int(time.time()) - 86400 * 3,
        "chat": {
            "history": {
                "currentId": "msg_2",
                "messages": {
                    "msg_1": {
                        "id": "msg_1",
                        "role": "user",
                        "content": "What is the American Dream and how has it evolved?",
                        "timestamp": int(time.time()) - 86400 * 3,
                    },
                    "msg_2": {
                        "id": "msg_2",
                        "role": "assistant",
                        "content": """The American Dream is the belief that anyone, regardless of their background, can achieve success and prosperity through hard work, determination, and initiative. This powerful idea has evolved significantly throughout American history.

**Origins of the American Dream**

The term was popularized by James Truslow Adams in 1931, but the concept dates back to the nation's founding:
- **Declaration of Independence (1776)**: "Life, Liberty, and the pursuit of Happiness"
- **Frontier Spirit**: The opportunity to claim land and build a new life
- **Immigration**: America as a land of opportunity for those seeking better lives

**Traditional Elements:**
1. **Homeownership**: Owning your own home and land
2. **Upward Mobility**: Children doing better than their parents
3. **Financial Security**: Steady job, savings, comfortable retirement
4. **Education**: Access to quality education as a path to success
5. **Freedom**: Personal liberty and self-determination

**Evolution Through the Decades:**

**Early 1900s**: Industrial opportunities drew millions to cities
- Factory jobs offered steady wages
- Immigrant communities built businesses

**Post-WWII Era (1945-1970)**: The "Golden Age"
- GI Bill provided education and home loans
- Suburban expansion
- Single income could support a family
- Manufacturing boom

**Late 20th Century**: Shifting landscape
- Service economy emergence
- Two-income households become norm
- College increasingly necessary
- Technology creates new opportunities

**21st Century American Dream:**
- **Entrepreneurship**: Start-up culture and gig economy
- **Work-Life Balance**: Not just material success
- **Diversity**: Expanding to include all Americans
- **Sustainability**: Environmental consciousness
- **Global Connectivity**: Opportunities beyond borders

**Modern Challenges and Opportunities:**
- Rising costs of education and housing
- Income inequality concerns
- But also: Digital economy creating new paths
- Innovation and creativity valued more than ever

**The Dream Endures:**
Despite challenges, the American Dream persists because it's not just about material success—it's about the freedom to pursue your own version of happiness and fulfillment. Whether that's starting a business, getting an education, raising a family, or serving your community, America continues to offer unique opportunities for those willing to work for them.

The Dream has always been about hope and possibility—and that remains as powerful today as it was for the Founders! 🌟🇺🇸""",
                        "timestamp": int(time.time()) - 86400 * 3 + 60,
                        "model": "gpt-4",
                    }
                }
            }
        },
        "meta": {
            "tags": ["culture", "economy", "society"]
        },
        "pinned": False,
        "archived": False,
        "share_id": None,
        "folder_id": None
    }
]


class DemoDataManager:
    """Manages demo data for demo users."""
    
    @staticmethod
    def get_demo_chats(user_id: str) -> List[Dict[str, Any]]:
        """
        Get demo chats for a demo user.
        Personalizes the chat IDs with the user's session.
        """
        demo_chats = []
        for chat in DEMO_CHATS:
            # Create a personalized copy for this demo user
            personalized_chat = chat.copy()
            personalized_chat["user_id"] = user_id
            # Keep the same chat IDs so they're consistent for the session
            demo_chats.append(personalized_chat)
        
        return demo_chats
    
    @staticmethod
    def get_demo_chat_by_id(chat_id: str, user_id: str) -> Dict[str, Any]:
        """Get a specific demo chat by ID."""
        for chat in DEMO_CHATS:
            if chat["id"] == chat_id:
                personalized_chat = chat.copy()
                personalized_chat["user_id"] = user_id
                return personalized_chat
        return None
    
    @staticmethod
    def is_demo_user(user) -> bool:
        """Check if a user is a demo user."""
        return hasattr(user, 'is_demo') and user.is_demo