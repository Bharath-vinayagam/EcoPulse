# backend/app/schemas.py
from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional, List


class UserCreate(BaseModel):
    username: str
    email: EmailStr
    password: str
    name: Optional[str] = ""


class UserLogin(BaseModel):
    username_or_email: str
    password: str


class UserProfile(BaseModel):
    id: int
    email: str
    name: str
    avatar_url: str
    total_points: int
    level: int
    streak_days: int
    monthly_co2_goal: float
    monthly_spending_goal: float
    dark_mode: bool
    
    class Config:
        from_attributes = True


class ExpenseCreate(BaseModel):
    user_id: Optional[int] = 1
    vendor: Optional[str] = "Unknown"
    amount: float
    date: Optional[datetime] = None
    items_text: Optional[str] = ""
    category: Optional[str] = None
    notes: Optional[str] = ""
    location: Optional[str] = ""


class ExpenseOut(BaseModel):
    id: int
    vendor: str
    amount: float
    date: datetime
    items_text: str
    category: str
    co2_kg: float
    notes: str
    location: str

    class Config:
        from_attributes = True


class SummaryOut(BaseModel):
    total_spend: float
    total_co2: float
    by_category: List[dict]


class MonthlyReport(BaseModel):
    month: str
    year: int
    total_spend: float
    total_co2: float
    avg_daily_co2: float
    top_category: str
    by_category: List[dict]
    daily_breakdown: List[dict]


class GoalCreate(BaseModel):
    user_id: Optional[int] = 1
    title: str
    description: Optional[str] = ""
    target_value: float
    goal_type: Optional[str] = "co2"
    category: Optional[str] = ""
    end_date: Optional[datetime] = None


class GoalOut(BaseModel):
    id: int
    title: str
    description: str
    target_value: float
    current_value: float
    goal_type: str
    category: str
    start_date: datetime
    end_date: datetime
    completed: bool
    progress_percent: float

    class Config:
        from_attributes = True


class AchievementOut(BaseModel):
    id: int
    name: str
    description: str
    icon: str
    points: int
    category: str
    unlocked: bool
    unlocked_at: Optional[datetime] = None

    class Config:
        from_attributes = True


class TipOut(BaseModel):
    id: int
    title: str
    content: str
    category: str
    potential_co2_saving: float
    icon: str

    class Config:
        from_attributes = True


class LeaderboardEntry(BaseModel):
    rank: int
    user_id: int
    name: str
    avatar_url: str
    total_points: int
    level: int
    total_co2_saved: float


class ComparisonData(BaseModel):
    your_co2: float
    average_co2: float
    your_rank: int
    total_users: int
    percentile: float
