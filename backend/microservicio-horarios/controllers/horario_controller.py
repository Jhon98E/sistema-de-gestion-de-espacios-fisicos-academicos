from sqlalchemy.orm import Session
from models.horario_model import Horario, HorarioDB
from fastapi import HTTPException, status
from controllers.services.notificacion_service import NotificacionService

notificacion_service = NotificacionService()

def obtener_horarios(db: Session):
    return db.query(HorarioDB).all()

def obtener_horario_por_id(id: int, db: Session):
    horario = db.query(HorarioDB).filter(HorarioDB.id == id).first()
    if not horario:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Horario con ID {id} no fue encontrado")
    return horario

async def crear_horario(data: Horario, db: Session, usuario_actual: dict):
    existe = db.query(HorarioDB).filter(
        HorarioDB.dia_semana == data.dia_semana,
        HorarioDB.hora_inicio == data.hora_inicio,
        HorarioDB.hora_fin == data.hora_fin,
        HorarioDB.jornada == data.jornada
    ).first()
    if existe:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="Ya existe un horario con esos datos")
    
    nuevo_horario = HorarioDB(
        dia_semana = data.dia_semana,
        hora_inicio = data.hora_inicio,
        hora_fin = data.hora_fin,
        jornada = data.jornada
    )
    
    db.add(nuevo_horario)
    db.commit()
    db.refresh(nuevo_horario)

    # 🔔 Enviar notificación (ajustar datos reales del usuario si se tienen)
    await notificacion_service.enviar_notificacion_horario(
        email = usuario_actual["email"],
        nombre_completo = usuario_actual["nombre_completo"],
        detalles={
            "dia": data.dia_semana,
            "hora_inicio": str(data.hora_inicio),
            "hora_fin": str(data.hora_fin),
            "jornada": data.jornada
        },
        accion="creado"
    )

    return nuevo_horario

def actualizar_horario(id: int, data: Horario, db: Session):
    horario_db = db.query(HorarioDB).filter(HorarioDB.id == id).first()
    if not horario_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Horario con ID {id} no fue encontrado")
    
    horario_db.dia_semana = data.dia_semana
    horario_db.hora_inicio = data.hora_inicio
    horario_db.hora_fin = data.hora_fin
    horario_db.jornada = data.jornada
    
    db.commit()
    db.refresh(horario_db)
    return horario_db

def eliminar_horario(id: int, db: Session):
    horario_db = db.query(HorarioDB).filter(HorarioDB.id == id).first()
    if not horario_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Horario con ID {id} no fue encontrado")
    
    db.delete(horario_db)
    db.commit()
    return {"message": "Horario eliminado exitosamente"}