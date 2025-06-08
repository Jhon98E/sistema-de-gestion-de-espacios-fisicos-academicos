from sqlalchemy.orm import Session
from models.horario_model import Horario, HorarioDB
from fastapi import HTTPException, status
from controllers.services.notificacion_service import NotificacionService
from sqlalchemy import and_

notificacion_service = NotificacionService()

def obtener_horarios(db: Session):
    return db.query(HorarioDB).all()

def obtener_horario_por_id(id: int, db: Session):
    horario = db.query(HorarioDB).filter(HorarioDB.id == id).first()
    if not horario:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Horario con ID {id} no fue encontrado")
    return horario

async def crear_horario(horario: Horario, db: Session, usuario_actual: dict):
    # Verificar si ya existe un horario con los mismos datos
    horario_existente = db.query(HorarioDB).filter(
        and_(
            HorarioDB.dia_semana == horario.dia_semana,
            HorarioDB.hora_inicio == horario.hora_inicio,
            HorarioDB.hora_fin == horario.hora_fin,
            HorarioDB.jornada == horario.jornada
        )
    ).first()

    if horario_existente:
        raise HTTPException(
            status_code=409,
            detail="Ya existe un horario con estos mismos datos"
        )

    try:
        horario_db = HorarioDB(
            dia_semana=horario.dia_semana,
            hora_inicio=horario.hora_inicio,
            hora_fin=horario.hora_fin,
            jornada=horario.jornada
        )
        db.add(horario_db)
        db.commit()
        db.refresh(horario_db)
        
        # Enviar notificación
        try:
            await notificacion_service.enviar_notificacion_horario(
                "Horario creado",
                f"Se ha creado un nuevo horario por {usuario_actual['nombre_completo']}"
            )
        except Exception as e:
            print(f"Error al enviar notificación: {e}")
        
        return horario_db
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Error al crear horario: {str(e)}"
        )

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