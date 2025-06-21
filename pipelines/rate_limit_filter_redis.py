"""
Rate Limiting Filter Pipeline with Redis Support
Provides persistent rate limiting across restarts
"""

import os
import time
import json
from typing import List, Optional, Dict
from pydantic import BaseModel
from collections import defaultdict
from fastapi import HTTPException

# Try to import redis, fall back to in-memory if not available
try:
    import redis
    REDIS_AVAILABLE = True
except ImportError:
    REDIS_AVAILABLE = False


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
        enable_redis: bool = bool(os.getenv("ENABLE_REDIS", "false").lower() == "true")
        redis_url: str = os.getenv("REDIS_URL", "redis://redis:6379/0")
        
    def __init__(self):
        self.type = "filter"
        self.name = "Rate Limit Filter (Redis)"
        self.valves = self.Valves()
        
        # Storage initialization
        self.redis_client = None
        self.user_requests: Dict[str, List[float]] = defaultdict(list)
        
        # Initialize Redis if enabled and available
        if self.valves.enable_redis and REDIS_AVAILABLE:
            try:
                self.redis_client = redis.from_url(self.valves.redis_url)
                self.redis_client.ping()
                print(f"Connected to Redis at {self.valves.redis_url}")
            except Exception as e:
                print(f"Failed to connect to Redis: {e}. Falling back to in-memory storage.")
                self.redis_client = None
        
    def _get_user_requests(self, user_id: str) -> List[float]:
        """Get user requests from Redis or memory"""
        if self.redis_client:
            try:
                key = f"rate_limit:{user_id}"
                data = self.redis_client.get(key)
                if data:
                    return json.loads(data)
                return []
            except Exception as e:
                print(f"Redis error: {e}")
                return self.user_requests.get(user_id, [])
        else:
            return self.user_requests.get(user_id, [])
    
    def _save_user_requests(self, user_id: str, requests: List[float]):
        """Save user requests to Redis or memory"""
        if self.redis_client:
            try:
                key = f"rate_limit:{user_id}"
                # Set with expiration time equal to sliding window
                expire_seconds = self.valves.sliding_window_minutes * 60
                self.redis_client.setex(key, expire_seconds, json.dumps(requests))
            except Exception as e:
                print(f"Redis error: {e}")
                self.user_requests[user_id] = requests
        else:
            self.user_requests[user_id] = requests
        
    def _clean_old_requests(self, requests: List[float], current_time: float) -> List[float]:
        """Remove requests older than the sliding window"""
        window_start = current_time - (self.valves.sliding_window_minutes * 60)
        return [ts for ts in requests if ts > window_start]
    
    def _check_rate_limits(self, requests: List[float], current_time: float) -> Optional[str]:
        """Check if user has exceeded any rate limits"""
        
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
        
        # Get and clean user requests
        requests = self._get_user_requests(user_id)
        requests = self._clean_old_requests(requests, current_time)
        
        # Check rate limits
        error_message = self._check_rate_limits(requests, current_time)
        if error_message:
            raise HTTPException(
                status_code=429,
                detail=error_message,
                headers={"Retry-After": "60"}  # Suggest retry after 60 seconds
            )
        
        # Record this request
        requests.append(current_time)
        self._save_user_requests(user_id, requests)
        
        return body
    
    async def outlet(self, body: dict, user: Optional[dict] = None) -> dict:
        """Pass through responses unchanged"""
        return body