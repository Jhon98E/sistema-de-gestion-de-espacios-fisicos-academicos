from pydantic import BaseModel

class Programa(BaseModel):
    nombre: str
    descripcion: str | None = None

    class Config:
        from_attributes = True