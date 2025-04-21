from pydantic import BaseModel
from sqlalchemy import Column, Integer, String
from database import Base

class Asignatura(BaseModel):
    id: int
    nombre: str
    programa: str 

class AsignaturaDB(Base):
    __tablename__ = "asignaturas"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, index=True, nullable=False)
    programa = Column(String, index=True, nullable=True)

    

