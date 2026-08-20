"""
Supabase PostgreSQL Migration Utility
Migrates all tables and records from local SQLite (data.db) to Supabase PostgreSQL.
"""

import sys
import os
import urllib.parse
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker

from app.database import Base
from app import models

def migrate(supabase_url: str):
    print("[1/5] Connecting to local SQLite database (data.db)...")
    sqlite_engine = create_engine("sqlite:///./data.db", connect_args={"check_same_thread": False})
    SqliteSession = sessionmaker(bind=sqlite_engine)
    sqlite_db = SqliteSession()

    if supabase_url.startswith("postgres://"):
        supabase_url = supabase_url.replace("postgres://", "postgresql://", 1)

    print("[2/5] Connecting to Supabase PostgreSQL...")
    supabase_engine = create_engine(supabase_url)
    SupabaseSession = sessionmaker(bind=supabase_engine)
    supabase_db = SupabaseSession()

    print("[3/5] Creating database tables in Supabase PostgreSQL...")
    Base.metadata.create_all(bind=supabase_engine)

    print("[4/5] Migrating Users...")
    users = sqlite_db.query(models.User).all()
    for u in users:
        sqlite_db.expunge(u)
        supabase_db.merge(u)
    supabase_db.commit()
    print(f"-> Migrated {len(users)} users.")

    print("[5/5] Migrating Expenses...")
    expenses = sqlite_db.query(models.Expense).all()
    for e in expenses:
        sqlite_db.expunge(e)
        supabase_db.merge(e)
    supabase_db.commit()
    print(f"-> Migrated {len(expenses)} expenses.")

    print("MIGRATION COMPLETE! All data successfully transferred to Supabase PostgreSQL.")
    sqlite_db.close()
    supabase_db.close()

if __name__ == "__main__":
    if len(sys.argv) > 1:
        url = sys.argv[1]
    else:
        url = input("Enter your Supabase Connection String: ").strip()
    
    if not url:
        print("Error: No Supabase Connection String provided.")
        sys.exit(1)
        
    migrate(url)
