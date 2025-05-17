import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base

BASE_DE_DATOS_URL = os.getenv("DATABASE_URL", "postgresql://postgres:root@db:5432/asignacion_espacios")

engine = create_engine(BASE_DE_DATOS_URL, echo=True)
sesion_local = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base=declarative_base()

def get_db():
    db = sesion_local()
    try:
        yield db
    finally:
        db.close()