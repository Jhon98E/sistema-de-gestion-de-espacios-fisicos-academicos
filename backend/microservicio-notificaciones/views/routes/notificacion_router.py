from fastapi import APIRouter
from models.notificacion import Notificacion
from controllers.services.rabbitmq_producer import enviar_mensaje

router = APIRouter(prefix="/notificaciones", tags=["Notificaciones"])

@router.post("/")
async def enviar_notificacion(notificacion: Notificacion):
    return enviar_mensaje(notificacion)
