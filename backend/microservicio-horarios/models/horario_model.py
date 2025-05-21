from typing import Optional
from enum import Enum
from pydantic import BaseModel
from sqlalchemy import Column, Integer, Enum as SQLAlchemyEnum, Time
from controllers.repositories.database import Base
import datetime


# Enum de Python para los días de la semana
class DiaSemana(str, Enum):
    lunes = "Lunes"
    martes = "Martes"
    miercoles = "Miércoles"
    jueves = "Jueves"
    viernes = "Viernes"
    sabado = "Sábado"

# Enum de Python para la jornada
class Jornada(str, Enum):
    diurno = "diurno"
    nocturno = "nocturno"

# Esquema Pydantic (para validación en la API)
class Horario(BaseModel):
    id: Optional[int] = None
    dia_semana: DiaSemana
    hora_inicio: datetime.time
    hora_fin: datetime.time   
    jornada: Jornada

    class Config:
        orm_mode = True


# Modelo SQLAlchemy (para la base de datos)
class HorarioDB(Base):
    __tablename__ = "horarios"

    id = Column(Integer, primary_key=True, index=True)
    dia_semana = Column(SQLAlchemyEnum(DiaSemana), nullable=False)
    hora_inicio = Column(Time, nullable=False)
    hora_fin = Column(Time, nullable=False)
    jornada = Column(SQLAlchemyEnum(Jornada), nullable=False)



    
    
