from fastapi import APIRouter
from models.asignatura_model import Asignatura
from controller import asignatura_controller


asignatura_router = APIRouter(prefix="/asignatura")


@asignatura_router.get('/')
async def consultar_asignaturas():
    return asignatura_controller.obtener_asignaturas()


@asignatura_router.get('/{id}')
async def consultar_asignaturas(id: int):
    return asignatura_controller.obtener_asignatura_por_id(id)


@asignatura_router.post('/crear-asignatura')
async def crear_asignatura(asignatura: Asignatura):
    return asignatura_controller.crear_asignatura(asignatura)


@asignatura_router.put('/actualizar-asignatura/{id}')
async def actualizar_asignatura(id: int, nueva_asignatura: Asignatura):
    return asignatura_controller.modificar_asignatura(id, nueva_asignatura)


@asignatura_router.delete('/eliminar-asignatura/{id}')
async def eliminar_asignatura(id: int):
    return asignatura_controller.eliminar_asignatura(id)
