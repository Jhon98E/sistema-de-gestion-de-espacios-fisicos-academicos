from models.cohortes_model import Cohorte, CohorteDB
from sqlalchemy.orm import Session
from fastapi import HTTPException, status
import httpx
from models.external.programa_model import Programa


PROGRAMAS_URL = "http://ms-programas:8001/programas"  # URL de tu microservicio de programas

# Función para verificar si el programa existe
async def verificar_programa_existe(programa_id: int):
    async with httpx.AsyncClient() as client:
        response = await client.get(f"{PROGRAMAS_URL}/{programa_id}")
        if response.status_code != 200:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail=f"El programa con ID {programa_id} no existe en el microservicio de programas."
            )


def obtenerCohortes(db: Session):
    return db.query(CohorteDB).all()

def obtenerCohortePorId(id: int, db: Session):
    cohorte = db.query(CohorteDB).filter(CohorteDB.id == id).first()
    if not cohorte:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"La cohorte con ID {id} no fue encontrada.")
    return cohorte

def obtenerCohortePorNombre(nombre: str, db: Session):
    cohorte = db.query(CohorteDB).filter(CohorteDB.nombre == nombre).first()
    if not cohorte:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"La cohorte con nombre {nombre} no fue encontrada.")
    return cohorte

# ✅ Ahora es async para poder usar await
async def crearCohorte(cohorte: Cohorte, db: Session):
    # Validar si la cohorte ya existe por nombre
    if db.query(CohorteDB).filter(CohorteDB.nombre == cohorte.nombre).first():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"La cohorte {cohorte.nombre} ya existe.")
    
    # ✅ Validar si el programa existe usando el microservicio
    await verificar_programa_existe(cohorte.programa_id)

    nueva_cohorte = CohorteDB(
        nombre=cohorte.nombre,
        programa_id=cohorte.programa_id,
        fecha_inicio=cohorte.fecha_inicio,
        fecha_fin=cohorte.fecha_fin,
        estado=cohorte.estado
    )
    db.add(nueva_cohorte)
    db.commit()
    db.refresh(nueva_cohorte)
    return nueva_cohorte


async def actualizarCohorte(id: int, cohorte_actualizada: Cohorte, db: Session):
    cohorte_db = db.query(CohorteDB).filter(CohorteDB.id == id).first()
    if not cohorte_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"La cohorte con ID {id} no fue encontrada.")
    
    # ✅ Validar si el programa existe antes de actualizar
    await verificar_programa_existe(cohorte_actualizada.programa_id)

    cohorte_db.nombre = cohorte_actualizada.nombre
    cohorte_db.programa_id = cohorte_actualizada.programa_id
    cohorte_db.fecha_inicio = cohorte_actualizada.fecha_inicio
    cohorte_db.fecha_fin = cohorte_actualizada.fecha_fin
    cohorte_db.estado = cohorte_actualizada.estado
    db.commit()
    db.refresh(cohorte_db)
    return cohorte_db


def eliminarCohorte(id: int, db: Session):
    cohorte_db = db.query(CohorteDB).filter(CohorteDB.id == id).first()
    if not cohorte_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"La cohorte con ID {id} no fue encontrada.")
    db.delete(cohorte_db)
    db.commit()
    return {"mensaje": "Cohorte eliminada correctamente"}
