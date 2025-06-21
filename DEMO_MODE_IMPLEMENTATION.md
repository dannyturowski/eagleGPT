# Demo Mode Implementation for EagleGPT

## Overview
This document outlines the implementation of a demo mode for EagleGPT that allows anonymous visitors to experience the full OpenWebUI interface in read-only mode with pre-populated patriotic content.

## Architecture

### Approach: Special Demo Token
Anonymous visitors are automatically authenticated with a special demo JWT token that provides read-only access to static demo data.

### Key Features
1. **Same UI**: Visitors see the exact same interface as logged-in users
2. **Auto-login**: No authentication required - automatic demo access
3. **Static Content**: Pre-populated patriotic themed chat threads
4. **Read-only**: Can browse and read, but all write actions redirect to signup
5. **Isolated Sessions**: Each visitor gets their own demo session

## Implementation Details

### Backend Components

#### 1. Demo Authentication Endpoint
- **Path**: `/api/auth/demo`
- **Method**: POST
- **Purpose**: Generate special JWT tokens for demo users
- **Token Properties**:
  - `is_demo: true` flag
  - Unique session ID
  - Short expiration (24 hours)
  - No database user created

#### 2. Auth Utils Modifications
- Modify `get_current_user` to recognize demo tokens
- Create virtual user objects for demo sessions:
  ```python
  {
      "id": f"demo_{session_id}",
      "email": f"demo_{session_id}@eaglegpt.us",
      "name": "Demo User",
      "role": "user",
      "is_demo": True
  }
  ```

#### 3. Demo Data Module
- **File**: `backend/open_webui/demo_data.py`
- **Content**: Pre-populated patriotic chat threads
- **Topics**:
  - "Exploring American Democracy"
  - "The Space Race and American Innovation"
  - "The American Dream Through History"
  - "Constitutional Rights Discussion"
  - "Great American Inventors"

#### 4. API Route Protection
- Block all write operations for demo users
- Return helpful error messages:
  ```json
  {
      "error": "Demo users cannot perform this action",
      "action": "signup",
      "message": "Sign up for a free account to start your own conversations"
  }
  ```

### Frontend Components

#### 1. Auto-login Flow
- **File**: `src/routes/+layout.svelte`
- Check if user is anonymous on mount
- Automatically call demo auth endpoint
- Store demo token in localStorage
- Continue with normal app flow

#### 2. Demo Utilities
- **File**: `src/lib/utils/demo.js`
- Helper functions:
  ```javascript
  export function isDemoUser(user) {
      return user?.is_demo === true;
  }
  
  export function showDemoRestriction() {
      toast.error('Sign up to start your own conversations', {
          action: {
              label: 'Sign Up',
              onClick: () => goto('/auth')
          }
      });
  }
  ```

#### 3. Write Action Interceptors
Intercept these actions and show signup prompt:
- Message submission (MessageInput.svelte)
- New chat creation (Sidebar.svelte)
- Settings changes
- Chat deletion/editing
- File uploads

#### 4. Demo Banner (Optional)
- Subtle banner at top: "Viewing as Demo User - Sign up for full access"
- Can be dismissed but reappears on refresh

## Implementation Steps

1. **Backend Demo Auth**
   - Create `/api/auth/demo` endpoint
   - Generate demo JWT tokens with `is_demo` flag

2. **Auth Utils Update**
   - Modify token validation to accept demo tokens
   - Create virtual demo user objects

3. **Demo Data Creation**
   - Create static patriotic chat threads
   - Include variety of conversation examples

4. **API Protection**
   - Add demo user checks to all write endpoints
   - Return consistent error messages

5. **Frontend Auto-login**
   - Detect anonymous users
   - Auto-authenticate with demo token
   - Handle token storage

6. **Write Action Blocking**
   - Add demo checks to all interactive components
   - Show signup prompts on write attempts

7. **Testing**
   - Verify anonymous users get demo access
   - Confirm all write actions are blocked
   - Test signup flow from demo mode

## Security Considerations

1. **Token Security**
   - Demo tokens are time-limited (24 hours)
   - Cannot access real user data
   - Cannot perform any write operations

2. **Data Isolation**
   - Demo users only see static demo data
   - No access to real database
   - No ability to affect other users

3. **Rate Limiting**
   - Limit demo token generation per IP
   - Prevent abuse of demo system

## User Experience Flow

1. Anonymous user visits eaglegpt.us
2. Automatically logged in as demo user (no loading screen)
3. Sees main chat interface with pre-populated threads
4. Can browse all threads and read messages
5. Attempting any action (send message, new chat, etc.) shows:
   - Toast notification: "Sign up to start your own conversations"
   - Button to go to signup page
6. After signup, user has full access with their own account

## Configuration

Add to environment variables:
```env
ENABLE_DEMO_MODE=true
DEMO_TOKEN_EXPIRY=86400  # 24 hours in seconds
```

## Benefits

1. **Low Friction**: Visitors immediately see the product
2. **Real Experience**: Full UI, not a limited demo
3. **Security**: No shared accounts or data risks
4. **Conversion**: Clear path from demo to signup
5. **Maintainable**: Minimal changes to existing code