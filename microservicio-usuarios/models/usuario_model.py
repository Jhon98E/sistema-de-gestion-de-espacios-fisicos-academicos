from typing import Optional
from pydantic import BaseModel
from sqlalchemy import Column, String, Integer
from database import Base

# Esquema para validación (Pydantic)
class Usuario(BaseModel):
    id: Optional[int] = None
    nombre: str
    apellido: str
    codigo_usuario: str
    rol: str
    email: str
    password: str

# Modelo para la base de datos (SQLAlchemy)
class UsuarioDB(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False)
    apellido = Column(String, nullable=False)
    codigo_usuario = Column(String, unique=True, nullable=False)
    rol = Column(String, nullable=False)
    email = Column(String, unique=True, nullable=False)
    password = Column(String, nullable=False)
