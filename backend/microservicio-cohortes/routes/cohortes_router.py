from fastapi import APIRouter
from models.cohortes_model import Cohorte
from controllers.cohortes_controller import *

cohortes_route = APIRouter(prefix="/cohortes")

@cohortes_route.get("/")
async def consultar_cohortes():
    return obtenerCohortes()

@cohortes_route.get("/{id}")
async def consultar_cohorte_por_id(id: int):
    return obtenerCohortePorId(id)

@cohortes_route.get("/consultar_por_nombre/{nombre}")
async def consultar_cohorte_por_nombre(nombre: str):
    return obtenerCohortePorNombre(nombre)

@cohortes_route.post("/crear_cohorte")
async def crear_cohorte(cohorte: Cohorte):
    return crearCohorte(cohorte)

@cohortes_route.put("/actualizar_cohorte/{id}")
async def actualizar_cohorte(id: int, cohorte: Cohorte):
    return actualizarCohorte(id, cohorte)

@cohortes_route.delete("/eliminar_cohorte/{id}")
async def eliminar_cohorte(id: int):
    return eliminarCohorte(id)

