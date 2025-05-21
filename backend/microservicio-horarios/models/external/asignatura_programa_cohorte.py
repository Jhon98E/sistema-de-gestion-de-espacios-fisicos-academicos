from sqlalchemy import Column, Integer, ForeignKey, Date
from datetime import date
from sqlalchemy.orm import relationship
from pydantic import BaseModel
from controllers.repositories.database import Base
from models.external.asignatura_programa import AsignaturaPrograma # noqa: F401
from models.external.salones_model import SalonDB # noqa: F401
from models.horario_model import HorarioDB # noqa: F401

class AsignaturaProgramaCohorteBase(BaseModel):
    asignatura_programa_id: int
    salon_id: int
    horario_id: int
    fecha_inicio: date
    fecha_fin: date
    
    class Config:
        orm_mode = True 

class AsignaturaProgramaCohorte(Base):
    __tablename__ = "asignaturas_programas_cohortes"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)  
    asignatura_programa_id = Column(Integer, ForeignKey('asignaturas_programas.id'), nullable=False)
    salon_id = Column(Integer, ForeignKey('salones.id'), nullable=False)
    horario_id = Column(Integer, ForeignKey('horarios.id'), nullable=False)
    fecha_inicio = Column(Date, nullable=False)
    fecha_fin = Column(Date, nullable=False)

    asignaturas_programas = relationship("AsignaturaPrograma", backref="asignaturas_programas_cohortes")
    salon = relationship("SalonDB", backref="asignatura_programa_cohorte")
    horarios = relationship("HorarioDB", backref="asignatura_programa_cohorte")
    
