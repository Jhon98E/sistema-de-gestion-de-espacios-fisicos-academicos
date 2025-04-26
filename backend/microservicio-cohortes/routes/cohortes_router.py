from fastapi import APIRouter, Depends
from models.cohortes_model import Cohorte
from controllers.cohortes_controller import *
from sqlalchemy.orm import Session
from database import get_db 


cohortes_route = APIRouter(prefix="/cohortes")

@cohortes_route.get("/")
async def consultar_cohortes(db: Session = Depends(get_db)):
    return obtenerCohortes()

@cohortes_route.get("/{id}")
async def consultar_cohorte_por_id(id: int, db: Session = Depends(get_db)):
    # Validar que el id de la cohorte no esté vacío
    return obtenerCohortePorId(id)

@cohortes_route.get("/consultar_por_nombre/{nombre}")
async def consultar_cohorte_por_nombre(nombre: str, db: Session = Depends(get_db)):
    # Validar que el nombre de la cohorte no esté vacío
    return obtenerCohortePorNombre(nombre)

@cohortes_route.post("/crear_cohorte")
async def crear_cohorte(cohorte: Cohorte, db: Session = Depends(get_db)):
    # Validar que el nombre de la cohorte no esté vacío
    return crearCohorte(cohorte)

@cohortes_route.put("/actualizar_cohorte/{id}")
async def actualizar_cohorte(id: int, cohorte: Cohorte, db: Session = Depends(get_db)):
    # Validar que el id de la cohorte no esté vacío
    return actualizarCohorte(id, cohorte)

@cohortes_route.delete("/eliminar_cohorte/{id}")
async def eliminar_cohorte(id: int, db: Session = Depends(get_db)):
    # Validar que el id de la cohorte no esté vacío
    return eliminarCohorte(id)
