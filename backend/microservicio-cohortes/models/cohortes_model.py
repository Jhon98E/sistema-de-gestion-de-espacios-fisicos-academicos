from pydantic import BaseModel
from sqlalchemy import Column, Integer, String
from controllers.repositories.database import Base


class Cohorte(BaseModel):
    id: int
    nombre: str
    programa_academico: str
    fecha_inicio: str
    estado: str


class CohorteDB(Base):
    __tablename__ = "cohortes"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, index=True, nullable=False)
    programa_academico = Column(String, index=True, nullable=False)
    fecha_inicio = Column(String, index=True, nullable=False)
    estado = Column(String, index=True, nullable=False)