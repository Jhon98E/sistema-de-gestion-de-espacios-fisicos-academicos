from fastapi import APIRouter, HTTPException, BackgroundTasks
from models.notificacion import (
    Notificacion, 
    NotificacionRegistroUsuario, 
    NotificacionRecuperacionPassword,
    NotificacionHorario,
    TipoNotificacion
)
from controllers.services.rabbitmq_producer import enviar_mensaje_rabbitmq
from controllers.notificacion_controller import NotificacionService
import logging

router = APIRouter(prefix="/notificaciones", tags=["Notificaciones"])
notificacion_service = NotificacionService()

@router.post("/enviar")
async def enviar_notificacion(notificacion: Notificacion, background_tasks: BackgroundTasks):
    """Endpoint para enviar notificaciones directamente"""
    try:
        # Enviar por RabbitMQ para procesamiento asíncrono
        await enviar_mensaje_rabbitmq(notificacion.dict())
        return {"mensaje": "Notificación enviada a la cola", "estado": "pendiente"}
    except Exception as e:
        logging.error(f"Error al enviar notificación: {e}")
        raise HTTPException(status_code=500, detail="Error interno del servidor")

@router.post("/registro-usuario")
async def enviar_notificacion_registro(datos: NotificacionRegistroUsuario):
    """Endpoint específico para notificaciones de registro de usuario"""
    try:
        notificacion = notificacion_service.crear_notificacion_registro(datos)
        await enviar_mensaje_rabbitmq(notificacion.dict())
        return {"mensaje": "Notificación de registro enviada"}
    except Exception as e:
        logging.error(f"Error al enviar notificación de registro: {e}")
        raise HTTPException(status_code=500, detail="Error interno del servidor")

@router.post("/horario")
async def enviar_notificacion_horario(datos: NotificacionHorario):
    """Endpoint específico para notificaciones de horarios"""
    try:
        notificacion = notificacion_service.crear_notificacion_horario(datos)
        await enviar_mensaje_rabbitmq(notificacion.dict())
        return {"mensaje": "Notificación de horario enviada"}
    except Exception as e:
        logging.error(f"Error al enviar notificación de horario: {e}")
        raise HTTPException(status_code=500, detail="Error interno del servidor")

@router.get("/health")
async def health_check():
    """Endpoint para verificar el estado del servicio"""
    return {"status": "ok", "service": "notificaciones"}