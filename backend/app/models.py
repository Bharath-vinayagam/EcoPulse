# backend/app/models.py
from sqlalchemy import Column, Integer, String, Float, DateTime, ForeignKey, Boolean, Text
from sqlalchemy.orm import relationship
from datetime import datetime
from .database import Base


class User(Base):
    __tablename__ = "users"
    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True, nullable=True)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)
    name = Column(String, default="")
    avatar_url = Column(String, default="")
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Gamification
    total_points = Column(Integer, default=0)
    level = Column(Integer, default=1)
    streak_days = Column(Integer, default=0)
    last_activity = Column(DateTime, default=datetime.utcnow)
    
    # Goals
    monthly_co2_goal = Column(Float, default=100.0)
    monthly_spending_goal = Column(Float, default=50000.0)
    
    # Settings
    dark_mode = Column(Boolean, default=False)
    notifications_enabled = Column(Boolean, default=True)

    expenses = relationship("Expense", back_populates="owner", cascade="all, delete-orphan")
    goals = relationship("Goal", back_populates="owner", cascade="all, delete-orphan")
    achievements = relationship("UserAchievement", back_populates="user", cascade="all, delete-orphan")


class Expense(Base):
    __tablename__ = "expenses"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    vendor = Column(String, default="Unknown")
    amount = Column(Float, nullable=False)
    date = Column(DateTime, default=datetime.utcnow)
    items_text = Column(String, default="")
    category = Column(String, default="Other")
    co2_kg = Column(Float, default=0.0)
    receipt_image_url = Column(String, default="")
    ocr_raw_text = Column(Text, default="")
    location = Column(String, default="")
    notes = Column(Text, default="")
    
    owner = relationship("User", back_populates="expenses")


class Goal(Base):
    __tablename__ = "goals"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    description = Column(Text, default="")
    target_value = Column(Float, nullable=False)
    current_value = Column(Float, default=0.0)
    goal_type = Column(String, default="co2")
    category = Column(String, default="")
    start_date = Column(DateTime, default=datetime.utcnow)
    end_date = Column(DateTime, nullable=False)
    completed = Column(Boolean, default=False)
    
    owner = relationship("User", back_populates="goals")


class Achievement(Base):
    __tablename__ = "achievements"
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, unique=True, nullable=False)
    description = Column(Text, nullable=False)
    icon = Column(String, default="🏆")
    points = Column(Integer, default=10)
    category = Column(String, default="general")


class UserAchievement(Base):
    __tablename__ = "user_achievements"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    achievement_id = Column(Integer, ForeignKey("achievements.id"), nullable=False)
    unlocked_at = Column(DateTime, default=datetime.utcnow)
    
    user = relationship("User", back_populates="achievements")
    achievement = relationship("Achievement")


class Tip(Base):
    __tablename__ = "tips"
    id = Column(Integer, primary_key=True, index=True)
    title = Column(String, nullable=False)
    content = Column(Text, nullable=False)
    category = Column(String, default="general")
    potential_co2_saving = Column(Float, default=0.0)
    icon = Column(String, default="💡")
