from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.orm import relationship
from controllers.repositories.database import Base
from models.external.cohortes_model import CohorteDB # noqa: F401
from models.external.asignatura_programa_cohorte import AsignaturaProgramaCohorte # noqa: F401

class AsignaturaProgramaCohorteDetalle(Base):
    __tablename__ = "asignaturas_programas_cohortes_detalles"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)
    asignatura_programa_cohorte_id = Column(Integer, ForeignKey('asignaturas_programas_cohortes.id'), nullable=False)
    cohorte_id = Column(Integer, ForeignKey('cohortes.id'), nullable=False)

    asignatura_programa_cohorte = relationship("AsignaturaProgramaCohorte", backref="asignaturas_programas_cohortes_detalles")
    cohorte = relationship("CohorteDB", backref="asignaturas_programas_cohortes_detalles")
