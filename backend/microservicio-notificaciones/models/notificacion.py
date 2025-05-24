from pydantic import BaseModel, EmailStr
from enum import Enum
from typing import Optional

class TipoNotificacion(str, Enum):
    REGISTRO_USUARIO = "registro_usuario"
    RECUPERACION_PASSWORD = "recuperacion_password"
    HORARIO_CREADO = "horario_creado"
    HORARIO_ACTUALIZADO = "horario_actualizado"
    HORARIO_ELIMINADO = "horario_eliminado"

class EstadoNotificacion(str, Enum):
    PENDIENTE = "pendiente"
    ENVIADO = "enviado"
    FALLIDO = "fallido"

class Notificacion(BaseModel):
    destinatario: EmailStr
    asunto: str
    mensaje: str
    tipo: TipoNotificacion
    estado: EstadoNotificacion = EstadoNotificacion.PENDIENTE
    datos_adicionales: Optional[dict] = None
    fecha_creacion: Optional[str] = None

class NotificacionRegistroUsuario(BaseModel):
    email: EmailStr
    nombre_completo: str
    codigo_usuario: str

class NotificacionRecuperacionPassword(BaseModel):
    email: EmailStr
    nombre_completo: str
    token_recuperacion: str

class NotificacionHorario(BaseModel):
    email: EmailStr
    nombre_completo: str
    accion: str
    detalles_horario: dict