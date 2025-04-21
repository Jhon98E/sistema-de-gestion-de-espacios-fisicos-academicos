from models.asignatura_model import AsignaturaDB, Asignatura
from sqlalchemy.orm import Session
from fastapi import HTTPException, status


def obtener_asignaturas(db: Session):
    return db.query(AsignaturaDB).all()


def obtener_asignatura_por_id(id: int, db: Session):
    asignatura = db.query(AsignaturaDB).filter(AsignaturaDB.id == id).first()
    if not asignatura:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"La asignatura con ID {id} no fue encontrada.")
    return asignatura


def crear_asignatura(asignatura: Asignatura, db: Session):
    if db.query(AsignaturaDB).filter(AsignaturaDB.nombre == asignatura.nombre).first():
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"La asignatura {asignatura.nombre} ya existe.")
    nueva_asignatura = AsignaturaDB(
        nombre=asignatura.nombre,
        programa=asignatura.programa
    )
    db.add(nueva_asignatura)
    db.commit()
    db.refresh(nueva_asignatura)
    return nueva_asignatura
    

def modificar_asignatura(id: int, asignatura: Asignatura, db: Session):
    asignatura_db = db.query(AsignaturaDB).filter(AsignaturaDB.id == id).first()
    if not asignatura_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"La asignatura con ID {id} no fue encontrada.")
    asignatura_db.nombre = asignatura.nombre
    asignatura_db.programa = asignatura.programa
    db.commit()
    db.refresh(asignatura_db)
    return asignatura_db


def eliminar_asignatura(id: int, db: Session):
    asignatura_db = db.query(AsignaturaDB).filter(AsignaturaDB.id == id).first()
    if not asignatura_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"La asignatura con ID {id} no fue encontrada.")
    db.delete(asignatura_db)
    db.commit()
    return {"message": f"La asignatura con ID {id} ha sido eliminada."}