from sqlalchemy.orm import Session
from models.programa_model import Programa
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
    # Verificar si ya existe un programa con el mismo nombre
    if db.query(Programa).filter(Programa.codigo_programa == str(data.codigo_programa)).first():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Ya existe un programa con este codigo de programa")

    nuevo_programa = Programa(
        nombre=data.nombre,
        descripcion=data.descripcion,
        codigo_programa=data.codigo_programa
    )
    db.add(nuevo_programa)
    db.commit()
    db.refresh(nuevo_programa)
    return nuevo_programa



def actualizar_programa(id: int, data: Programa, db: Session): 
    programa_db = db.query(Programa).filter(Programa.id == id).first()

    if not programa_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Programa con ID {id} no fue encontrado")

    # Excluir el mismo programa de la validación de duplicado
    if db.query(Programa).filter(
        Programa.codigo_programa == data.codigo_programa,
        Programa.id != id
    ).first():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Ya existe un programa con este codigo de programa")

    programa_db.nombre = data.nombre
    programa_db.descripcion = data.descripcion
    programa_db.codigo_programa = data.codigo_programa

    db.commit()
    db.refresh(programa_db)
    return programa_db

def eliminar_programa(id: int, db: Session):
    programa_db = db.query(Programa).filter(Programa.id == id).first()
    if not programa_db:  
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Programa con ID {id} no fue encontrado")

    db.delete(programa_db)
    db.commit()
    return {"message": "Programa eliminado exitosamente"}
