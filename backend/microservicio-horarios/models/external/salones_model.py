from pydantic import BaseModel
from typing import Optional
from controllers.repositories.database import Base
from sqlalchemy import Column, String, Integer, Boolean

class Salon(BaseModel):
    id: Optional[int] = None
    nombre: str
    capacidad: int
    disponibilidad: bool
    tipo: str
    class Config:
        orm_mode = True


class SalonDB(Base):
    __tablename__ = "salones"

    id= Column(Integer, primary_key= True, index=True)
    nombre = Column(String, nullable=False)
    capacidad = Column(Integer, nullable=False)
    disponibilidad = Column(Boolean, nullable=False)
    tipo = Column(String, nullable=True)