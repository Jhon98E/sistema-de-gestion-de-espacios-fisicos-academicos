from typing import Optional
from pydantic import BaseModel
from sqlalchemy import Column, String, Integer
from controllers.repositories.database import Base

# Esquema para validación (Pydantic)
class Horario(BaseModel):
    id: Optional[int] = None
    hora_inicio: str
    hora_fin: str
    dia: str


# Modelo para la base de datos (SQLAlchemy)
class HorarioDB(Base):
    __tablename__ = "horarios"

    id = Column(Integer, primary_key=True, index=True)
    hora_inicio = Column(String, nullable=False)
    hora_fin = Column(String, nullable=False)
    dia = Column(String, nullable=False)
