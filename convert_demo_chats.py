#!/usr/bin/env python3
"""
Convert exported OpenWebUI chat JSON files to demo chat format.
This script extracts the conversation structure but replaces content with appropriate patriotic themes.
"""
import json
import os
import time
from typing import List, Dict, Any

def sanitize_and_convert_chat(chat_data: Dict[str, Any], demo_id: str, title: str, theme_content: Dict[str, str]) -> Dict[str, Any]:
    """Convert a chat export to demo format with sanitized content."""
    
    # Extract the chat structure
    original_chat = chat_data[0]  # Chat exports are arrays with one item
    original_messages = original_chat["chat"]["history"]["messages"]
    
    # Create new demo-appropriate messages
    demo_messages = {}
    message_order = []
    
    # Get message order by following the conversation chain
    current_id = None
    for msg_id, msg in original_messages.items():
        if msg.get("parentId") is None:
            current_id = msg_id
            break
    
    msg_counter = 1
    while current_id:
        original_msg = original_messages[current_id]
        new_msg_id = f"msg_{msg_counter}"
        
        # Create sanitized message content
        if original_msg["role"] == "user":
            content = theme_content.get(f"user_{msg_counter}", "Tell me about American values and traditions")
        else:
            content = theme_content.get(f"assistant_{msg_counter}", "America represents the best ideals of freedom, democracy, and opportunity for all!")
        
        demo_messages[new_msg_id] = {
            "id": new_msg_id,
            "role": original_msg["role"],
            "content": content,
            "timestamp": int(time.time()) - 86400 * (len(message_order) + 1),  # Spread over days
        }
        
        if original_msg["role"] == "assistant":
            demo_messages[new_msg_id]["model"] = "gpt-4"
        
        message_order.append(new_msg_id)
        msg_counter += 1
        
        # Find next message in chain
        next_id = None
        if "childrenIds" in original_msg and original_msg["childrenIds"]:
            next_id = original_msg["childrenIds"][0]
        current_id = next_id
        
        # Limit to reasonable conversation length
        if msg_counter > 10:
            break
    
    # Set parent/child relationships
    for i, msg_id in enumerate(message_order):
        if i > 0:
            demo_messages[msg_id]["parentId"] = message_order[i-1]
            demo_messages[message_order[i-1]]["childrenIds"] = [msg_id]
        else:
            demo_messages[msg_id]["parentId"] = None
        
        if msg_id not in [m["parentId"] for m in demo_messages.values() if m.get("parentId")]:
            demo_messages[msg_id]["childrenIds"] = []
    
    # Create demo chat structure
    demo_chat = {
        "id": demo_id,
        "title": title,
        "created_at": int(time.time()) - 86400 * len(message_order),
        "updated_at": int(time.time()) - 86400,
        "chat": {
            "history": {
                "currentId": message_order[-1] if message_order else "msg_1",
                "messages": demo_messages
            }
        },
        "meta": {
            "tags": ["patriotism", "america", "values", "history"]
        },
        "pinned": False,
        "archived": False,
        "share_id": None,
        "folder_id": None
    }
    
    return demo_chat

# Patriotic themes for replacement content
DEMO_THEMES = {
    "american_education": {
        "title": "Excellence in American Education",
        "user_1": "What makes American education special?",
        "assistant_1": """American education has always been built on the principle that knowledge should be accessible to all citizens in a free society. Here's what makes it unique:

**Foundational Principles:**
- **Public Education for All**: From the earliest days, America believed every child deserves an education
- **Local Control**: Communities have a say in how their schools are run
- **Innovation and Creativity**: Encouraging students to think critically and solve problems
- **Practical Learning**: Combining theoretical knowledge with real-world applications

**Historic Achievements:**
- **Land Grant Universities**: Made higher education accessible to working families
- **GI Bill**: Helped millions of veterans attend college after WWII
- **Community Colleges**: Providing affordable pathways to success
- **Research Universities**: Leading global innovation in science and technology

**American Educational Values:**
- Encouraging debate and diverse perspectives
- Teaching civic responsibility and constitutional principles
- Fostering entrepreneurship and innovation
- Celebrating achievement while supporting those who struggle

The goal has always been to create informed citizens who can participate fully in our democracy while pursuing their own American Dreams! 📚🇺🇸""",
        "user_2": "How has American education evolved over time?",
        "assistant_2": """American education has constantly evolved to meet the changing needs of our nation while maintaining core democratic values:

**Early America (1600s-1800s):**
- One-room schoolhouses in rural communities
- Focus on reading, writing, arithmetic, and moral instruction
- Many schools started by religious communities
- McGuffey Readers teaching both literacy and values

**Industrial Era (1900-1950):**
- Compulsory education laws ensuring all children attend school
- Standardized curriculum and grade levels
- Vocational training for industrial jobs
- Immigration waves led to English language instruction

**Modern Era (1950-Present):**
- Integration and civil rights in education
- Special education programs for students with disabilities
- Technology integration and digital literacy
- STEM education emphasis
- School choice and charter school movements

**Continuing Strengths:**
- Adaptability to changing economic needs
- Local community involvement in schools
- Emphasis on critical thinking and creativity
- Extracurricular activities developing well-rounded citizens
- Higher education system that attracts students worldwide

American education continues to evolve because we believe every generation should have better opportunities than the last! 🎓✨"""
    },
    "american_innovation": {
        "title": "American Innovation and Entrepreneurship",
        "user_1": "What drives American innovation?",
        "assistant_1": """American innovation springs from the unique combination of freedom, opportunity, and the entrepreneurial spirit that defines our nation:

**Cultural Foundations:**
- **Freedom to Fail**: In America, failure is seen as a learning opportunity, not a permanent setback
- **Risk-Taking Spirit**: From the pioneers to modern entrepreneurs, Americans aren't afraid to try new things
- **Individual Initiative**: Belief that anyone with a good idea and hard work can succeed
- **Competitive Markets**: Free enterprise encourages continuous improvement and innovation

**Key Drivers:**
- **Patent System**: Protecting intellectual property encourages invention
- **Venture Capital**: Risk-tolerant investors fund new ideas
- **University Research**: World-class institutions driving scientific breakthroughs
- **Immigration**: Bringing diverse perspectives and talent from around the world
- **Military Research**: Defense needs have sparked countless civilian innovations

**Innovation Examples:**
- **Edison's Lab**: The first industrial research facility
- **Silicon Valley**: From garages to global tech giants
- **Biotech Revolution**: American companies leading medical breakthroughs
- **Space Technology**: From moon landings to private space companies

**The American Advantage:**
Americans don't just accept "that's how it's always been done." We ask "how can we do it better?" This restless pursuit of improvement, combined with the freedom to pursue our ideas, has made America the world's innovation leader! 🚀💡""",
        "user_2": "What are some recent examples of American innovation?",
        "assistant_2": """American innovation continues to lead the world across multiple industries:

**Technology & Digital Innovation:**
- **Artificial Intelligence**: Companies like OpenAI, Google, and Microsoft pushing AI boundaries
- **Electric Vehicles**: Tesla revolutionizing automotive industry
- **Social Media Platforms**: Facebook, Twitter, Instagram connecting the world
- **Cloud Computing**: Amazon Web Services, Microsoft Azure powering global internet

**Medical & Biotechnology:**
- **mRNA Vaccines**: Developed in record time during COVID-19 pandemic
- **Cancer Immunotherapy**: Revolutionary treatments saving lives
- **Gene Therapy**: Treating previously incurable genetic diseases
- **Robotic Surgery**: Precision medicine improving patient outcomes

**Energy & Environment:**
- **Fracking Technology**: Unlocking American energy independence
- **Solar Panel Efficiency**: Making renewable energy more affordable
- **Battery Technology**: Extended range for electric vehicles and grid storage
- **Nuclear Innovation**: Next-generation reactor designs

**Aerospace & Defense:**
- **SpaceX**: Reusable rockets making space accessible
- **James Webb Telescope**: Revealing secrets of the universe
- **Military Drones**: Protecting American interests worldwide
- **Hypersonic Technology**: Next-generation defense capabilities

The American spirit of innovation isn't slowing down—it's accelerating! Our entrepreneurs, scientists, and inventors continue to solve problems and create opportunities that benefit not just America, but the entire world! 🌟🇺🇸"""
    },
    "american_freedom": {
        "title": "The Meaning of American Freedom",
        "user_1": "What does freedom mean in America?",
        "assistant_1": """Freedom in America is more than just a word—it's the foundation of everything we stand for and the promise we make to every citizen:

**Core Freedoms:**
- **Freedom of Speech**: The right to express your views, even unpopular ones
- **Freedom of Religion**: Worship as you choose, or choose not to worship at all
- **Freedom of Assembly**: Gather peacefully to make your voice heard
- **Freedom of the Press**: Independent media holding power accountable
- **Economic Freedom**: Pursue your own prosperity through free enterprise

**What Makes American Freedom Unique:**
- **Constitutional Protection**: These rights are written down and protected by law
- **Limited Government**: Government power is restricted to protect individual liberty
- **Equal Justice**: Same rules apply to everyone, regardless of status
- **Opportunity**: Freedom includes the chance to improve your circumstances

**Responsibilities That Come With Freedom:**
- **Civic Participation**: Voting, serving on juries, staying informed
- **Respecting Others' Rights**: Your freedom ends where another's begins
- **National Service**: Many choose military, Peace Corps, or community service
- **Vigilance**: Protecting freedom requires constant attention

**The American Promise:**
Freedom means you can criticize the government without fear, start a business with just an idea and hard work, practice your faith openly, travel freely across 50 states, and pursue happiness in your own way.

It's not perfect—we've had to fight to extend these freedoms to all Americans—but the principle remains: in America, you are free to write your own story! 🗽⭐""",
        "user_2": "How do we protect and preserve American freedoms?",
        "assistant_2": """Protecting American freedoms requires active participation from every generation of citizens:

**Constitutional Safeguards:**
- **Separation of Powers**: Executive, Legislative, and Judicial branches check each other
- **Bill of Rights**: First 10 amendments explicitly protect core freedoms
- **Independent Judiciary**: Courts can overturn laws that violate constitutional rights
- **Federalism**: Power divided between federal and state governments

**Citizen Responsibilities:**
- **Stay Informed**: Read, research, and think critically about issues
- **Vote Regularly**: In local, state, and federal elections
- **Participate Locally**: Town halls, school boards, community organizations
- **Serve When Called**: Jury duty, military service, volunteer work

**Institutional Protections:**
- **Free Press**: Supporting independent journalism and diverse media sources
- **Civil Rights Organizations**: Groups like ACLU defending constitutional rights
- **Educational System**: Teaching civics and constitutional principles
- **Military**: Oath to defend the Constitution against all enemies

**Ongoing Vigilance:**
- **Question Authority**: Healthy skepticism of government power
- **Defend Unpopular Speech**: Freedom only matters when it's tested
- **Support Equal Justice**: Ensuring laws apply fairly to everyone
- **Engage Across Differences**: Democracy requires listening to opposing views

**The Price of Freedom:**
As Thomas Jefferson said, "The price of freedom is eternal vigilance." Each generation must actively choose to preserve what previous generations sacrificed to create. Freedom isn't automatic—it's earned every day through the choices we make as citizens! 🦅🇺🇸"""
    }
}

def main():
    """Convert demo chat files."""
    demo_dir = "/mnt/c/eaglegpt/demo"
    output_chats = []
    
    # Get all JSON files
    json_files = [f for f in os.listdir(demo_dir) if f.endswith('.json')]
    
    themes = list(DEMO_THEMES.keys())
    
    for i, filename in enumerate(json_files[:3]):  # Limit to 3 for now
        filepath = os.path.join(demo_dir, filename)
        
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                chat_data = json.load(f)
            
            # Use a theme for this chat
            theme_key = themes[i % len(themes)]
            theme = DEMO_THEMES[theme_key]
            
            demo_id = f"demo_chat_{i + 6}"  # Start from 6 since we have 5 already
            
            demo_chat = sanitize_and_convert_chat(chat_data, demo_id, theme["title"], theme)
            output_chats.append(demo_chat)
            
            print(f"Converted {filename} -> {demo_chat['title']}")
            
        except Exception as e:
            print(f"Error converting {filename}: {e}")
    
    # Output the Python code to add to demo_data.py
    print("\n# Add these to the DEMO_CHATS list in demo_data.py:")
    for chat in output_chats:
        print(f"    {json.dumps(chat, indent=4)},")

if __name__ == "__main__":
    main()