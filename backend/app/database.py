# backend/app/database.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
import os

try:
    from dotenv import load_dotenv
    load_dotenv()
except ImportError:
    pass

DEFAULT_SUPABASE_URL = "postgresql+psycopg://postgres.jneayqjixcenrjrzewtu:cric12%23smartco2@aws-0-ap-northeast-2.pooler.supabase.com:6543/postgres"

raw_db_url = os.getenv("DATABASE_URL", DEFAULT_SUPABASE_URL)
if raw_db_url.startswith("postgresql://") and "psycopg" not in raw_db_url:
    raw_db_url = raw_db_url.replace("postgresql://", "postgresql+psycopg://", 1)
if raw_db_url.startswith("postgres://"):
    raw_db_url = raw_db_url.replace("postgres://", "postgresql+psycopg://", 1)

DATABASE_URL = raw_db_url

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}
)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
