from sqlalchemy import Column, Integer, String
from app.database import Base

class Programa(Base):
    __tablename__ = "programas"

    id = Column(Integer, primary_key=True, index=True)
    nombre = Column(String, index=True)    
    descripcion = Column(String, index=True)