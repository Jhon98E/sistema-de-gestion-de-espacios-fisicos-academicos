from sqlalchemy import Column, Integer, String
from controllers.repositories.database import Base
from sqlalchemy.orm import relationship

class Programa(Base):
    __tablename__ = "programas"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, nullable=False, index=True)    
    descripcion = Column(String, nullable=True)
    codigo_programa = Column(String(4), nullable=False, unique=True)

    