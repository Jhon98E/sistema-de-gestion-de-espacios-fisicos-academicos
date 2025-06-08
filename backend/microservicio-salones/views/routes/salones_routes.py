from fastapi import APIRouter, Depends
from models.salones_model import Salon
from sqlalchemy.orm import Session
from controllers.repositories.database import get_db
from controllers.salones_controller import (
    consultar_salones,
    obtener_salon,
    crear_salon,
    actualizar_salon,
    eliminar_salon,
)
from controllers.services.auth_service import obtener_usuario_actual

salon_router = APIRouter(prefix="/salones", tags=["Salones"])

@salon_router.get("/")
async def route_consultar_salones(db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return consultar_salones(db)

@salon_router.get("/{salon_id}")
async def route_obtener_salon(salon_id: int, db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return obtener_salon(db, salon_id)

@salon_router.post("/")
async def route_crear_salon(salon: Salon, db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return crear_salon(salon, db)

@salon_router.put("/{salon_id}")
async def route_actualizar_salon(salon_id: int, salon_actualizado: Salon, db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return actualizar_salon(db, salon_id, salon_actualizado)

@salon_router.delete("/{salon_id}")
async def route_eliminar_salon(salon_id: int, db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return eliminar_salon(db, salon_id)
