from sqlalchemy.orm import Session
from models.horario_model import Horario, HorarioDB
from fastapi import HTTPException, status

def obtener_horarios(db: Session):
    return db.query(HorarioDB).all()

def obtener_horario_por_id(id: int, db: Session):
    usuario = db.query(HorarioDB).filter(HorarioDB.id == id).first()
    if not usuario:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario con ID {id} no fue encontrado")
    return usuario

def crear_horario(data: Horario, db: Session):
    # Verificar duplicados
    if db.query(HorarioDB).filter(HorarioDB.id == data.id).first():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="El usuario con ese email o código ya existe")
    
    nuevo_horario = HorarioDB(
        hora_inicio = data.hora_inicio,
        hora_fin = data.hora_fin,
        dia = data.dia
    )
    
    db.add(nuevo_horario)
    db.commit()
    db.refresh(nuevo_horario)
    return nuevo_horario

def actualizar_horario(id: int, data: Horario, db: Session):
    horario_db = db.query(HorarioDB).filter(HorarioDB.id == id).first()
    if not horario_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario con ID {id} no fue encontrado")
    
    horario_db.hora_inicio = data.hora_inicio
    horario_db.hora_fin = data.hora_fin
    horario_db.dia = data.dia
    
    db.commit()
    db.refresh(horario_db)
    return horario_db

def eliminar_horario(id: int, db: Session):
    horario_db = db.query(HorarioDB).filter(HorarioDB.id == id).first()
    if not horario_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario con ID {id} no fue encontrado")
    
    db.delete(horario_db)
    db.commit()
    return {"message": "Usuario eliminado exitosamente"}
