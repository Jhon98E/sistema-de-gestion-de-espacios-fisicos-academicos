from pydantic import BaseModel
from sqlalchemy import Column, Integer, String, ForeignKey, Date
from controllers.repositories.database import Base
from models.external.programa_model import Programa # noqa: F401
from sqlalchemy.orm import relationship
from datetime import date


class Cohorte(BaseModel):
    id: int
    nombre: str
    programa_id: int
    fecha_inicio: date   
    fecha_fin: date      
    estado: str
    
    class Config:
        orm_mode = True


class CohorteDB(Base):
    __tablename__ = "cohortes"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, index=True, nullable=False)
    programa_id = Column(Integer, ForeignKey("programas.id"), nullable=False)
    fecha_inicio = Column(Date, nullable=False)   # Cambiado de String a Date
    fecha_fin = Column(Date, nullable=False)      # Cambiado de String a Date
    estado = Column(String, index=True, nullable=False)

    programa = relationship("Programa", backref="cohortes")