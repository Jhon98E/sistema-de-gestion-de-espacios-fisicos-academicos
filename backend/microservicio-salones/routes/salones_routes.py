from fastapi import APIRouter, Depends
from models.salones_model import Salon
from sqlalchemy.orm import Session
from database import get_db
from controllers.salones_controller import (
    consultar_salones,
    obtener_salon,
    crear_salon,
    actualizar_salon,
    eliminar_salon,
)

salon_router = APIRouter()

@salon_router.get("/")
async def route_consultar_salones(db:Session = Depends(get_db)):
    return consultar_salones()

@salon_router.get("/{salon_id}")
async def route_obtener_salon(salon_id: int, db:Session = Depends(get_db)):
    return obtener_salon(salon_id)

@salon_router.post("/")
async def route_crear_salon(salon: Salon, db:Session = Depends(get_db)):
    return crear_salon(salon)

@salon_router.put("/{salon_id}")
async def route_actualizar_salon(salon_id: int, salon_actualizado: Salon, db:Session = Depends(get_db)):
    return actualizar_salon(salon_id, salon_actualizado)

@salon_router.delete("/{salon_id}")
async def route_eliminar_salon(salon_id: int, db:Session = Depends(get_db)):
    return eliminar_salon(salon_id)
