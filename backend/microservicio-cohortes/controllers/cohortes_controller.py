from models.cohortes_model import Cohorte, CohorteDB
from sqlalchemy.orm import Session
from fastapi import HTTPException, status


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

def crearCohorte(cohorte: Cohorte, db: Session):
    if db.query(CohorteDB).filter(CohorteDB.nombre == cohorte.nombre).first():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"La cohorte {cohorte.nombre} ya existe.")
    nueva_cohorte = CohorteDB(
        nombre=cohorte.nombre,
        programa_academico=cohorte.programa_academico,
        fecha_inicio=cohorte.fecha_inicio,
        estado=cohorte.estado
    )
    db.add(nueva_cohorte)
    db.commit()
    db.refresh(nueva_cohorte)
    return nueva_cohorte

def actualizarCohorte(id: int, cohorte_actualizada, db: Session):
    cohorte_db = db.query(CohorteDB).filter(CohorteDB.id == id).first()
    if not cohorte_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"La cohorte con ID {id} no fue encontrada.")
    cohorte_db.nombre = cohorte_actualizada.nombre
    cohorte_db.programa_academico = cohorte_actualizada.programa_academico
    cohorte_db.fecha_inicio = cohorte_actualizada.fecha_inicio
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
    return {"mensaje": f"La cohorte con ID {id} ha sido eliminada."}