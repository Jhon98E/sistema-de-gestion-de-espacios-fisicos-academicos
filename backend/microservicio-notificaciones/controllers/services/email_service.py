import smtplib
import os
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from models.notificacion import Notificacion, EstadoNotificacion
import logging
from typing import Dict, Any

class EmailService:
    def __init__(self):
        self.smtp_server = os.getenv("SMTP_SERVER", "smtp.gmail.com")
        self.smtp_port = int(os.getenv("SMTP_PORT", "587"))
        self.smtp_usuario = os.getenv("SMTP_USUARIO")
        self.smtp_password = os.getenv("SMTP_PASSWORD")
        self.remitente = os.getenv("EMAIL_REMITENTE", self.smtp_usuario)
        
        if not all([self.smtp_usuario, self.smtp_password]):
            raise ValueError("Variables de entorno SMTP_USUARIO y SMTP_PASSWORD son requeridas")
    
    async def enviar_correo(self, notificacion_data: Dict[str, Any]) -> bool:
        """Enviar correo electrónico"""
        try:
            destinatario = notificacion_data["destinatario"]
            asunto = notificacion_data["asunto"]
            mensaje = notificacion_data["mensaje"]
            
            # Crear mensaje
            msg = MIMEMultipart()
            msg["From"] = self.remitente
            msg["To"] = destinatario
            msg["Subject"] = asunto
            
            # Agregar cuerpo del mensaje
            msg.attach(MIMEText(mensaje, "plain", "utf-8"))
            
            # Conectar y enviar
            with smtplib.SMTP(self.smtp_server, self.smtp_port) as servidor:
                servidor.starttls()
                servidor.login(self.smtp_usuario, self.smtp_password)
                servidor.send_message(msg)
            
            logging.info(f"✅ Correo enviado exitosamente a {destinatario}")
            return True
            
        except Exception as e:
            logging.error(f"❌ Error al enviar correo a {destinatario}: {e}")
            return False