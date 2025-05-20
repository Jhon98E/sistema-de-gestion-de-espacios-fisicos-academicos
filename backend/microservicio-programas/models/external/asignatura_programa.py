from sqlalchemy import Column, Integer, ForeignKey
from sqlalchemy.orm import relationship
from controllers.repositories.database import Base
from models.external.asignatura_model import AsignaturaDB  # noqa: F401
from models.programa_model import Programa  # noqa: F401

# Tabla puente entre Asignatura y Programa
class AsignaturaPrograma(Base):
    __tablename__ = "asignaturas_programas"
    
    id = Column(Integer, primary_key=True, index=True, autoincrement=True)  
    asignatura_id = Column(Integer, ForeignKey('asignaturas.id'), nullable=False)
    programa_id = Column(Integer, ForeignKey('programas.id'), nullable=False)

    asignatura = relationship("AsignaturaDB", backref="asignaturas_programas")
    programa = relationship("Programa", backref="asignaturas_programas")
