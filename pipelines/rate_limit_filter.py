"""
Rate Limiting Filter Pipeline for OpenWebUI
Provides configurable rate limiting with multiple strategies
"""

import os
import time
from typing import List, Optional, Dict
from pydantic import BaseModel
from collections import defaultdict
from fastapi import HTTPException


class Pipeline:
    class Valves(BaseModel):
        pipelines: List[str] = ["*"]  # Apply to all models by default
        priority: int = 0  # High priority to run before other filters
        
        # Rate limiting configuration
        requests_per_minute: Optional[int] = int(os.getenv("RATE_LIMIT_PER_MINUTE", "10"))
        requests_per_hour: Optional[int] = int(os.getenv("RATE_LIMIT_PER_HOUR", "50"))
        sliding_window_limit: Optional[int] = int(os.getenv("RATE_LIMIT_SLIDING_WINDOW", "100"))
        sliding_window_minutes: Optional[int] = int(os.getenv("RATE_LIMIT_SLIDING_WINDOW_MINUTES", "180"))
        
        # Options
        exempt_admin: bool = True
        
    def __init__(self):
        self.type = "filter"
        self.name = "Rate Limit Filter"
        self.valves = self.Valves()
        
        # In-memory storage for request tracking
        self.user_requests: Dict[str, List[float]] = defaultdict(list)
        
    def _clean_old_requests(self, user_id: str, current_time: float):
        """Remove requests older than the sliding window"""
        if user_id in self.user_requests:
            window_start = current_time - (self.valves.sliding_window_minutes * 60)
            self.user_requests[user_id] = [
                ts for ts in self.user_requests[user_id] 
                if ts > window_start
            ]
    
    def _check_rate_limits(self, user_id: str, current_time: float) -> Optional[str]:
        """Check if user has exceeded any rate limits"""
        requests = self.user_requests.get(user_id, [])
        
        # Check per-minute limit
        if self.valves.requests_per_minute:
            one_minute_ago = current_time - 60
            recent_requests = sum(1 for ts in requests if ts > one_minute_ago)
            if recent_requests >= self.valves.requests_per_minute:
                return f"Rate limit exceeded: {self.valves.requests_per_minute} requests per minute"
        
        # Check per-hour limit
        if self.valves.requests_per_hour:
            one_hour_ago = current_time - 3600
            recent_requests = sum(1 for ts in requests if ts > one_hour_ago)
            if recent_requests >= self.valves.requests_per_hour:
                return f"Rate limit exceeded: {self.valves.requests_per_hour} requests per hour"
        
        # Check sliding window limit
        if self.valves.sliding_window_limit and len(requests) >= self.valves.sliding_window_limit:
            return f"Rate limit exceeded: {self.valves.sliding_window_limit} requests per {self.valves.sliding_window_minutes} minutes"
        
        return None
    
    async def inlet(self, body: dict, user: Optional[dict] = None) -> dict:
        """Process request before it reaches the LLM"""
        
        # Skip rate limiting if no user info
        if not user:
            return body
            
        user_id = user.get("id", "anonymous")
        user_role = user.get("role", "user")
        
        # Exempt admin users if configured
        if self.valves.exempt_admin and user_role == "admin":
            return body
        
        current_time = time.time()
        
        # Clean old requests
        self._clean_old_requests(user_id, current_time)
        
        # Check rate limits
        error_message = self._check_rate_limits(user_id, current_time)
        if error_message:
            raise HTTPException(
                status_code=429,
                detail=error_message,
                headers={"Retry-After": "60"}  # Suggest retry after 60 seconds
            )
        
        # Record this request
        self.user_requests[user_id].append(current_time)
        
        return body
    
    async def outlet(self, body: dict, user: Optional[dict] = None) -> dict:
        """Pass through responses unchanged"""
        return body