from pydantic import BaseModel
from typing import Optional

# Define tu esquema Pydantic para la creación
class AsignaturaProgramaCohorteCreate(BaseModel):
    asignatura_programa_id: int
    salon_id: int
    horario_id: int
    fecha_inicio: str # Usar el tipo de dato correcto para fechas, posiblemente date o datetime
    fecha_fin: str   # Usar el tipo de dato correcto para fechas, posiblemente date o datetime

    class Config:
        orm_mode = True

# Define tu esquema Pydantic para la respuesta/lectura
class AsignaturaProgramaCohorteResponse(BaseModel):
    id: int
    asignatura_programa_id: int
    salon_id: int
    horario_id: int
    fecha_inicio: str # Usar el tipo de dato correcto
    fecha_fin: str   # Usar el tipo de dato correcto
    # Puedes añadir campos adicionales si tu API los retorna (ej: detalles de asignatura/programa/salon)

    class Config:
        orm_mode = True

# Opcional: Define un esquema para la actualización si es diferente de la creación
class AsignaturaProgramaCohorteUpdate(BaseModel):
    asignatura_programa_id: Optional[int] = None
    salon_id: Optional[int] = None
    horario_id: Optional[int] = None
    fecha_inicio: Optional[str] = None
    fecha_fin: Optional[str] = None

    class Config:
        orm_mode = True 