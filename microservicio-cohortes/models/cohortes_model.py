from pydantic import BaseModel

class Cohorte(BaseModel):
    id: int
    nombre: str
    programa_academico: str
    fecha_inicio: str
    estado: str

cohortes = [
    Cohorte(id=1, nombre="Cohorte1", programa_academico="Ingeniería de Sistemas", fecha_inicio="2021-01-01", estado="Activa"),
    Cohorte(id=2, nombre="Cohorte2", programa_academico="Ingeniería de Sistemas", fecha_inicio="2021-01-01", estado="Activa"),
    ]
