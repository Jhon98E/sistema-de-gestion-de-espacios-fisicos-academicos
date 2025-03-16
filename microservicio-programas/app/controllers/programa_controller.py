from sqlalchemy.orm import Session
from app.models.programa_model import Programa
from fastapi import HTTPException, status

def obtener_programas(db: Session):
    return db.query(Programa).all()

def obtener_programa_por_id(id: int, db: Session):
    programa = db.query(Programa).filter(Programa.id == id).first()
    if not programa:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Programa con ID {id} no fue encontrado")
    return programa

def crear_programa(data: Programa, db: Session):
    # Verificar si ya existe un programa con el mismo nombre
    if db.query(Programa).filter(Programa.nombre == data.nombre).first():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Ya existe un programa con este nombre")

    nuevo_programa = Programa(
        nombre=data.nombre,
        descripcion=data.descripcion
    )
    db.add(nuevo_programa)
    db.commit()
    db.refresh(nuevo_programa)
    return nuevo_programa

def actualizar_programa(id: int, data: Programa, db: Session):
    programa_db = db.query(Programa).filter(Programa.id == id).first()
    if not programa_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Programa con ID {id} no fue encontrado")

    programa_db.nombre= data.nombre
    programa_db.descripcion= data.descripcion
    
    db.commit()
    db.refresh(programa_db)
    return programa_db

def eliminar_programa(id: int, db: Session):
    programa_db = db.query(ProgramaDB).filter(ProgramaDB.id == id).first()
    if not programa_db:  
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Programa con ID {id} no fue encontrado")

    db.delete(programa_db)
    db.commit()
    return {"message": "Programa eliminado exitosamente"}
