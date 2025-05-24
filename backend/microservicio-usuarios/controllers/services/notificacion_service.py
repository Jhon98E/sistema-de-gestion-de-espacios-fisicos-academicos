import httpx
import os
import logging

class NotificacionService:
    def __init__(self):
        self.base_url = os.getenv("NOTIFICACIONES_SERVICE_URL", "http://localhost:8006")
        self.timeout = 10.0
    
    async def enviar_notificacion_registro(self, email: str, nombre_completo: str, codigo_usuario: str) -> bool:
        """Enviar notificación de registro de usuario"""
        try:
            url = f"{self.base_url}/notificaciones/registro-usuario"
            payload = {
                "email": email,
                "nombre_completo": nombre_completo,
                "codigo_usuario": codigo_usuario
            }
            
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(url, json=payload)
                
            if response.status_code == 200:
                logging.info(f"✅ Notificación de registro enviada exitosamente para {email}")
                return True
            else:
                logging.error(f"❌ Error al enviar notificación de registro: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            logging.error(f"❌ Error en servicio de notificaciones (registro): {e}")
            return False
    
    async def enviar_notificacion_recuperacion(self, email: str, nombre_completo: str, token_recuperacion: str) -> bool:
        """Enviar notificación de recuperación de contraseña"""
        try:
            url = f"{self.base_url}/notificaciones/recuperacion-password"
            payload = {
                "email": email,
                "nombre_completo": nombre_completo,
                "token_recuperacion": token_recuperacion
            }
            
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(url, json=payload)
                
            if response.status_code == 200:
                logging.info(f"✅ Notificación de recuperación enviada exitosamente para {email}")
                return True
            else:
                logging.error(f"❌ Error al enviar notificación de recuperación: {response.status_code} - {response.text}")
                return False
                
        except Exception as e:
            logging.error(f"❌ Error en servicio de notificaciones (recuperación): {e}")
            return False