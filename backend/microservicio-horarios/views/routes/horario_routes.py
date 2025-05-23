from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from controllers.repositories.database import get_db
from models.horario_model import Horario
from controllers import horario_controller


horario_router = APIRouter(prefix="/horarios", tags=["Horarios"])

@horario_router.get("/", response_model=list[Horario])
async def consultar_horarios(db: Session = Depends(get_db)):
    return horario_controller.obtener_horarios(db)

@horario_router.get("/{id}", response_model=Horario)
async def consultar_horario(id: int, db: Session = Depends(get_db)):
    return horario_controller.obtener_horario_por_id(id, db)

@horario_router.post("/crear-horario", response_model=Horario, status_code=201)
async def crear_horario(horario: Horario, db: Session = Depends(get_db)):
    return horario_controller.crear_horario(horario, db)

@horario_router.put("/actualizar-horario/{id}", response_model=Horario)
async def actualizar_horario(id: int, horario: Horario, db: Session = Depends(get_db)):
    return horario_controller.actualizar_horario(id, horario, db)

@horario_router.delete("/eliminar-horario/{id}", status_code=200)
async def eliminar_horario(id: int, db: Session = Depends(get_db)):
    return horario_controller.eliminar_horario(id, db)
