import httpx
import os
import logging

class NotificacionService:
    def __init__(self):
        self.base_url = os.getenv("NOTIFICACIONES_SERVICE_URL", "http://ms-notificaciones:8006")
        self.timeout = 10.0

    async def enviar_notificacion_horario(self, email: str, nombre_completo: str, detalles: dict, accion: str = "creado") -> bool:
        try:
            url = f"{self.base_url}/notificaciones/horario"
            payload = {
                "email": email,
                "nombre_completo": nombre_completo,
                "accion": accion,
                "detalles_horario": detalles
            }

            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(url, json=payload)

            if response.status_code == 200:
                logging.info("✅ Notificación de horario enviada")
                return True
            else:
                logging.error(f"❌ Error al enviar notificación: {response.status_code} - {response.text}")
                return False

        except Exception as e:
            logging.error(f"❌ Error al conectar con servicio de notificaciones: {e}")
            return False
