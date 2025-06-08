from fastapi import APIRouter, status, Depends
from models.cohortes_model import Cohorte
from controllers.cohortes_controller import obtenerCohortes, obtenerCohortePorId, obtenerCohortePorNombre, crearCohorte, actualizarCohorte, eliminarCohorte
from sqlalchemy.orm import Session
from controllers.repositories.database import get_db
from controllers.services.auth.auth_service import obtener_usuario_actual


cohortes_route = APIRouter(prefix="/cohortes", tags=["Cohortes"])


@cohortes_route.get("/")
async def consultar_cohortes(db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return obtenerCohortes(db)

@cohortes_route.get("/{id}")
async def consultar_cohorte_por_id(id: int, db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return obtenerCohortePorId(id, db)

@cohortes_route.get("/consultar_por_nombre/{nombre}")
async def consultar_cohorte_por_nombre(nombre: str, db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return obtenerCohortePorNombre(nombre, db)

@cohortes_route.post("/crear_cohorte", status_code=status.HTTP_201_CREATED)
async def crear_cohorte(cohorte: Cohorte, db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return await crearCohorte(cohorte, db)

@cohortes_route.put("/actualizar_cohorte/{id}")
async def actualizar_cohorte(id: int, cohorte: Cohorte, db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return await actualizarCohorte(id, cohorte, db)

@cohortes_route.delete("/eliminar_cohorte/{id}")
async def eliminar_cohorte(id: int, db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return eliminarCohorte(id, db)