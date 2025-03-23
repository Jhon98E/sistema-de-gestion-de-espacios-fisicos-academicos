from pydantic import BaseModel

class Asignatura(BaseModel):
    id: int
    nombre: str

asignaturas = {
    Asignatura(id=1, nombre="Matematicas"),
    Asignatura(id=2, nombre="Desarrollo de Software")
}