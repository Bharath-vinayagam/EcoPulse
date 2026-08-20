# backend/app/auth.py
import re
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from sqlalchemy import or_
from passlib.hash import bcrypt
from .database import get_db
from . import models, schemas

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/register")
def register(user: schemas.UserCreate, db: Session = Depends(get_db)):
    username = user.username.strip().lower()
    email = user.email.strip().lower()
    password = user.password

    if len(username) < 3:
        raise HTTPException(status_code=400, detail="Username must be at least 3 characters long.")
    
    if len(password) < 6:
        raise HTTPException(status_code=400, detail="Strong password required: minimum 6 characters.")

    if db.query(models.User).filter(models.User.username == username).first():
        raise HTTPException(status_code=400, detail="Username is already taken. Please choose another username.")

    if db.query(models.User).filter(models.User.email == email).first():
        raise HTTPException(status_code=400, detail="Email is already registered. Please login instead.")

    u = models.User(
        username=username,
        email=email,
        name=user.name or username.capitalize(),
        password_hash=bcrypt.hash(password)
    )
    db.add(u)
    db.commit()
    db.refresh(u)
    return {"id": u.id, "username": u.username, "email": u.email, "name": u.name}


@router.post("/login")
def login(creds: schemas.UserLogin, db: Session = Depends(get_db)):
    identifier = creds.username_or_email.strip().lower()

    u = db.query(models.User).filter(
        or_(models.User.username == identifier, models.User.email == identifier)
    ).first()

    if not u or not bcrypt.verify(creds.password, u.password_hash):
        raise HTTPException(status_code=401, detail="Invalid username/email or password.")

    return {"user_id": u.id, "username": u.username or u.email.split('@')[0], "email": u.email, "name": u.name}
