from models.notificacion import (
    Notificacion, 
    NotificacionRegistroUsuario,
    NotificacionHorario,
    TipoNotificacion,
    EstadoNotificacion
)
from datetime import datetime
from config.templates import TEMPLATES_EMAIL

class NotificacionService:
    
    def crear_notificacion_registro(self, datos: NotificacionRegistroUsuario) -> Notificacion:
        """Crear notificación para registro de usuario"""
        asunto = "¡Bienvenido al Sistema de Gestión de Espacios!"
        mensaje = TEMPLATES_EMAIL["registro_usuario"].format(
            nombre_completo=datos.nombre_completo,
            codigo_usuario=datos.codigo_usuario
        )
        
        return Notificacion(
            destinatario=datos.email,
            asunto=asunto,
            mensaje=mensaje,
            tipo=TipoNotificacion.REGISTRO_USUARIO,
            estado=EstadoNotificacion.PENDIENTE,
            fecha_creacion=datetime.now().isoformat(),
            datos_adicionales={
                "nombre_completo": datos.nombre_completo,
                "codigo_usuario": datos.codigo_usuario
            }
        )
    
    def crear_notificacion_horario(self, datos: NotificacionHorario) -> Notificacion:
        """Crear notificación para cambios en horarios"""
        tipo_map = {
            "creado": TipoNotificacion.HORARIO_CREADO,
            "actualizado": TipoNotificacion.HORARIO_ACTUALIZADO,
            "eliminado": TipoNotificacion.HORARIO_ELIMINADO
        }
        
        asunto = f"Horario {datos.accion} - Sistema de Gestión de Espacios"
        mensaje = TEMPLATES_EMAIL["horario"].format(
            nombre_completo=datos.nombre_completo,
            accion=datos.accion,
            detalles=str(datos.detalles_horario)
        )
        
        return Notificacion(
            destinatario=datos.email,
            asunto=asunto,
            mensaje=mensaje,
            tipo=tipo_map.get(datos.accion, TipoNotificacion.HORARIO_ACTUALIZADO),
            estado=EstadoNotificacion.PENDIENTE,
            fecha_creacion=datetime.now().isoformat(),
            datos_adicionales={
                "nombre_completo": datos.nombre_completo,
                "accion": datos.accion,
                "detalles_horario": datos.detalles_horario
            }
        )