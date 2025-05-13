from pydantic import BaseModel
from sqlalchemy import Column, Integer, String
from controllers.repositories.database import Base

class Asignatura(BaseModel):
    id: int
    nombre: str
    codigo_asignatura: str
    

class AsignaturaDB(Base):
    __tablename__ = "asignaturas"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, index=True, nullable=False)
    codigo_asignatura = Column(String(7), nullable=False, unique=True)
