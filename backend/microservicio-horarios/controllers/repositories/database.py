import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base


# Formato: postgresql://usuario:password@host:puerto/nombre_bd
BASE_DE_DATOS_URL = os.getenv("DATABASE_URL", "postgresql://postgres:root@db:5432/asignacion_espacios")

engine = create_engine(url=BASE_DE_DATOS_URL, echo=True)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()