from fastapi import HTTPException
from models.salones_model import Salon, SalonDB
from sqlalchemy.orm import Session

def consultar_salones(db:Session):
    return db.query(SalonDB).all()

def obtener_salon(db: Session, salon_id: int):
    salon = db.query(SalonDB).filter(SalonDB.id == salon_id).first()
    if not salon:
        raise HTTPException(status_code=404, detail="Salón no encontrado")
    return salon

def crear_salon(salon: Salon, db:Session):
    if db.query(SalonDB).filter(SalonDB.nombre == salon.nombre).first():
        raise HTTPException(status_code=400, detail="Salón ya existe")
    
    nuevo_salon = SalonDB(
        nombre=salon.nombre,        
        capacidad=salon.capacidad,
        disponibilidad=salon.disponibilidad,
        tipo=salon.tipo,
    )
    
    db.add(nuevo_salon)
    db.commit()
    db.refresh(nuevo_salon)
    return nuevo_salon

def actualizar_salon(db:Session, salon_id: int, salon:Salon):
    salon_db = db.query(SalonDB).filter(SalonDB.id == salon_id).first()
    if not salon_db:
        raise HTTPException(status_code=404, detail="Salón no encontrado")
    
    salon_db.nombre=salon.nombre
    salon_db.capacidad=salon.capacidad
    salon_db.disponibilidad=salon.disponibilidad
    salon_db.tipo=salon.tipo

    db.commit()
    db.refresh(salon_db)
    return salon_db

def eliminar_salon(db: Session, salon_id: int):
    salon = db.query(SalonDB).filter(SalonDB.id == salon_id).first()
    if not salon:
        raise HTTPException(status_code=404, detail="Salón no encontrado")
    db.delete(salon)
    db.commit()
    return {"message": f"Salón {salon_id} eliminado"}
