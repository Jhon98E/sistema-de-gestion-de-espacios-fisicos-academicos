import smtplib
from config import MAIL_SERVER, MAIL_PORT, MAIL_USERNAME, MAIL_PASSWORD

class CorreoServicio:
    def enviar_correo(self, notificacion):
        try:
            server = smtplib.SMTP(MAIL_SERVER, MAIL_PORT)
            server.starttls()
            server.login(MAIL_USERNAME, MAIL_PASSWORD)
            message = f"Subject: {notificacion.asunto}\n\n{notificacion.mensaje}"
            server.sendmail(MAIL_USERNAME, notificacion.destinatario, message)
            server.quit()
            return True
        except Exception as e:
            print(f"Error enviando correo: {e}")
            return False
