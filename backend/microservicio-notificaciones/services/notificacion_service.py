# services/notificacion_service.py

import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

def enviar_correo(notificacion):
    remitente = "rmolinomolina@gmail.com"
    destinatario = notificacion["destinatario"]
    asunto = notificacion["asunto"] 
    cuerpo = notificacion["cuerpo"]

    smtp_server = "smtp.gmail.com"
    smtp_port = 587
    smtp_usuario = "rmolinomolina@gmail.com"
    smtp_password = "pqiz npbd fwec joie"  # Usa una contraseña de aplicación

    try:
        mensaje = MIMEMultipart()
        mensaje["From"] = remitente
        mensaje["To"] = destinatario
        mensaje["Subject"] = asunto
        mensaje.attach(MIMEText(cuerpo, "plain"))

        servidor = smtplib.SMTP(smtp_server, smtp_port)
        servidor.starttls()
        servidor.login(smtp_usuario, smtp_password)
        servidor.sendmail(remitente, destinatario, mensaje.as_string())
        servidor.quit()

        print("✅ Correo enviado")
    except Exception as e:
        print(f"❌ Error al enviar correo: {e}")
