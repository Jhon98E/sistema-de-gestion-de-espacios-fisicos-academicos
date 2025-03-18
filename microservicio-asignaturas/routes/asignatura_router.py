from fastapi import APIRouter, HTTPException, status
from models.asignatura_model import asignaturas, Asignatura


asignatura_router = APIRouter(prefix="/asignatura")


@asignatura_router.get('/')
async def consultar_asignaturas():
    return asignaturas


@asignatura_router.get('/{id}')
async def consultar_id(id: int):
    for asignatura in asignaturas:
        if asignatura.id == id:
            return asignatura
    return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario con {id} no encontrado")


@asignatura_router.post('/crear-asignatura')
async def crear_asignatura(asignatura: Asignatura):
    asignaturas.append(asignatura)
    return HTTPException(status_code=status.HTTP_201_CREATED, detail=f"se creo la asignatura {asignatura} exitosamente.")


@asignatura_router.put('/modificar-asignatura/{id}')
async def modificar_asignatura(id: int, nueva_asignatura: Asignatura):
    for asignatura in asignaturas:
        if asignatura.id == id:
            asignatura.nombre = nueva_asignatura.nombre
            return HTTPException(status_code=status.HTTP_201_CREATED, detail=f"La asignatura con ID {id} se modifico exitosamente.")
    return {'message': 'No se modifico nada'}


@asignatura_router.delete('/eliminar-asignatura/{id}')
async def eliminar_asignatura(id: int):
    for asignatura in asignaturas:
        if asignatura.id == id:
            asignaturas.remove(asignatura)
            return {'message': f'Se removio la asignatura,{asignatura}'}
    return {'message': 'No se borro nada'}
