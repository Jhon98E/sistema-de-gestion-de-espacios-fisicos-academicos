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
        
        # Obtener destinatarios (docentes y coordinadores)
        destinatarios = await notificacion_service.obtener_destinatarios_por_rol(["docente", "coordinador"])
        
        # Preparar detalles del horario para la notificación
        detalles = {
            "dia": horario_db.dia_semana.value,
            "hora_inicio": str(horario_db.hora_inicio),
            "hora_fin": str(horario_db.hora_fin),
            "jornada": horario_db.jornada.value,
            "creado_por": usuario_actual["nombre_completo"]
        }
        
        # Enviar notificación
        await notificacion_service.enviar_notificacion_horario(
            destinatarios=destinatarios,
            detalles_horario=detalles,
            accion="creado"
        )
        
        return horario_db
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Error al crear horario: {str(e)}"
        )

async def actualizar_horario(id: int, data: Horario, db: Session, usuario_actual: dict):
    horario_db = db.query(HorarioDB).filter(HorarioDB.id == id).first()
    if not horario_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, 
            detail=f"Horario con ID {id} no fue encontrado"
        )
    
    # Guardar datos anteriores para la notificación
    datos_anteriores = {
        "dia": horario_db.dia_semana.value,
        "hora_inicio": str(horario_db.hora_inicio),
        "hora_fin": str(horario_db.hora_fin),
        "jornada": horario_db.jornada.value
    }
    
    # Actualizar datos
    horario_db.dia_semana = data.dia_semana
    horario_db.hora_inicio = data.hora_inicio
    horario_db.hora_fin = data.hora_fin
    horario_db.jornada = data.jornada
    
    try:
        db.commit()
        db.refresh(horario_db)
        
        # Obtener destinatarios
        destinatarios = await notificacion_service.obtener_destinatarios_por_rol(["docente", "coordinador"])
        
        # Preparar detalles para la notificación
        detalles = {
            "datos_anteriores": datos_anteriores,
            "datos_nuevos": {
                "dia": horario_db.dia_semana.value,
                "hora_inicio": str(horario_db.hora_inicio),
                "hora_fin": str(horario_db.hora_fin),
                "jornada": horario_db.jornada.value
            },
            "actualizado_por": usuario_actual["nombre_completo"]
        }
        
        # Enviar notificación
        await notificacion_service.enviar_notificacion_horario(
            destinatarios=destinatarios,
            detalles_horario=detalles,
            accion="actualizado"
        )
        
        return horario_db
        
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=500,
            detail=f"Error al actualizar horario: {str(e)}"
        )

def eliminar_horario(id: int, db: Session):
    horario_db = db.query(HorarioDB).filter(HorarioDB.id == id).first()
    if not horario_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Horario con ID {id} no fue encontrado")
    
    db.delete(horario_db)
    db.commit()
    return {"message": "Horario eliminado exitosamente"}