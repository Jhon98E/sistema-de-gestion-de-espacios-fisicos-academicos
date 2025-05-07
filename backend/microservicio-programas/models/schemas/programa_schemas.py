from pydantic import BaseModel

class Programa(BaseModel):
    nombre: str
    descripcion: str | None = None
    codigo_programa: str
    
    class Config:
        from_attributes = True