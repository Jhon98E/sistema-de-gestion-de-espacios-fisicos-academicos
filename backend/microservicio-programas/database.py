import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base
from config import DATABASE_URL

engine = create_engine(DATABASE_URL)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()
print("DATABASE_URL:", os.getenv("DATABASE_URL"))
# Agregar la función get_db
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
