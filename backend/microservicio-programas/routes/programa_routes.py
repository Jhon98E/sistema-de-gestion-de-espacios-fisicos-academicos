from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from controllers import programa_controller
from schemas.programa_schemas import Programa as ProgramaSchema
from fastapi import APIRouter, Depends

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
