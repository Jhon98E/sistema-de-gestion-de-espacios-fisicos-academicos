import os
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base


# Asegúrate de configurar la URL de tu BD PostgreSQL
# Formato: postgresql://usuario:password@host:puerto/nombre_bd
BASE_DE_DATOS_URL = os.getenv("DATABASE_URL", "postgresql://postgres:root@localhost:5432/usuarios")

engine = create_engine(url=BASE_DE_DATOS_URL, echo=True)  # echo=True para ver las queries en consola (opcional)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()