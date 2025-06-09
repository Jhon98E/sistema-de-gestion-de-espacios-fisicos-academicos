import httpx
import os
import logging
from typing import Dict, Any

class NotificacionService:
    def __init__(self):
        self.base_url = os.getenv("NOTIFICACIONES_SERVICE_URL", "http://ms-notificaciones:8006")
        self.timeout = 10.0

    async def enviar_notificacion_horario(
        self, 
        destinatarios: list[Dict[str, str]], 
        detalles_horario: dict, 
        accion: str
    ):
        """
        Envía notificaciones a múltiples destinatarios sobre cambios en horarios
        
        Args:
            destinatarios: Lista de diccionarios con email y nombre_completo de los destinatarios
            detalles_horario: Detalles del horario modificado
            accion: Tipo de acción realizada (creado, actualizado, eliminado)
        """
        try:
            url = f"{self.base_url}/notificaciones/horario-multiple"
            
            payload = {
                "destinatarios": destinatarios,
                "accion": accion,
                "detalles_horario": detalles_horario
            }

            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(url, json=payload)

            if response.status_code == 200:
                logging.info(f"✅ Notificaciones de horario enviadas ({len(destinatarios)} destinatarios)")
                return True
            else:
                logging.error(f"❌ Error al enviar notificaciones: {response.status_code} - {response.text}")
                return False

        except Exception as e:
            logging.error(f"❌ Error al conectar con servicio de notificaciones: {e}")
            return False

    async def obtener_destinatarios_por_rol(self, roles: list[str]) -> list[Dict[str, str]]:
        """
        Obtiene lista de usuarios por roles desde el microservicio de usuarios
        """
        try:
            usuarios_service_url = os.getenv("USUARIOS_SERVICE_URL", "http://ms-usuarios:8000")
            url = f"{usuarios_service_url}/usuarios/por-roles"
            
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(url, json={"roles": roles})
                
            if response.status_code == 200:
                return response.json()
            else:
                logging.error(f"❌ Error al obtener usuarios: {response.status_code}")
                return []
                
        except Exception as e:
            logging.error(f"❌ Error al conectar con servicio de usuarios: {e}")
            return []
