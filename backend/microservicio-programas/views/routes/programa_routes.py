from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from controllers.repositories.database import get_db
from controllers import programa_controller
from controllers.external import asignatura_programa_controller
from models.schemas.programa_schemas import Programa as ProgramaSchema
from models.schemas.external.asignatura_programa_schemas import AsignaturaProgramaSchema


router = APIRouter()

router = APIRouter(prefix="/programas", tags=["Programas"])

@router.get("/")
def obtener_programas(db: Session = Depends(get_db)):
    return programa_controller.obtener_programas(db)

@router.get("/{id}")
def obtener_programa(id: int, db: Session = Depends(get_db)):
    return programa_controller.obtener_programa_por_id(id, db)

@router.post("/")
def crear_programa(data: ProgramaSchema, db: Session = Depends(get_db)):
    return programa_controller.crear_programa(data, db)

@router.put("/{id}")
def actualizar_programa(id: int, data: ProgramaSchema, db: Session = Depends(get_db)):
    return programa_controller.actualizar_programa(id, data, db)

@router.delete("/{id}")
def eliminar_programa(id: int, db: Session = Depends(get_db)):
    return programa_controller.eliminar_programa(id, db)

@router.post("/asignar_asignatura")
async def asignar_asignatura_a_programa(data: AsignaturaProgramaSchema, db: Session = Depends(get_db)):
    return await asignatura_programa_controller.asignar_asignatura_programa(data, db)

@router.get("/asignaturas_programas/")
def listar_asignaturas_programas(db: Session = Depends(get_db)):
    return asignatura_programa_controller.obtener_todas_asignaturas_programas(db)

@router.get("/asignaturas_programas/{id}")
async def obtener_asignatura_programa(id: int, db: Session = Depends(get_db)):
    return asignatura_programa_controller.obtener_asignatura_programa_por_id(id, db)

@router.delete("/asignaturas_programas/{id}")
def eliminar_asignatura_programa(id: int, db: Session = Depends(get_db)):
    return asignatura_programa_controller.eliminar_asignatura_programa(id, db)
