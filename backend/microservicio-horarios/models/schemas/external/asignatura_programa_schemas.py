from pydantic import BaseModel

class AsignaturaProgramaSchema(BaseModel):
    asignatura_id: int
    programa_id: int

    class Config:
        orm_mode = True
