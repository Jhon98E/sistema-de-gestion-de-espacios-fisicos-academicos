from models.asignatura_model import asignaturas
from fastapi import HTTPException, status


def obtener_asignaturas():
    return asignaturas


def obtener_asignatura_por_id(id: int):
    for asignatura in asignaturas:
        if asignatura.id == id:
            return asignatura
    return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario con {id} no encontrado")


def crear_asignatura(asignatura):
    asignaturas.append(asignatura)
    return HTTPException(status_code=status.HTTP_201_CREATED, detail=f"se creo la asignatura {asignatura} exitosamente.")


def modificar_asignatura(id: int, nueva_asignatura):
    for asignatura in asignaturas:
        if asignatura.id == id:
            asignatura.nombre = nueva_asignatura.nombre
            return HTTPException(status_code=status.HTTP_201_CREATED, detail=f"La asignatura con ID {id} se modifico exitosamente.")
    return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"La asignatura con ID {id} no fue encontrada.")


def eliminar_asignatura(id: int):
    for asignatura in asignaturas:
        if asignatura.id == id:
            asignaturas.remove(asignatura)
            return {'message': f'Se removio la asignatura,{asignatura}'}
    return HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"La asignatura con ID {id} no fue encontrada.")
