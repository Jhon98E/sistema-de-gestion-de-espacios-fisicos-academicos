import pika
import json


RABBITMQ_HOST = "localhost"
QUEUE_NAME = "cola_notificaciones"

def enviar_mensaje(notificacion):
    try:
        conexion = pika.BlockingConnection(pika.ConnectionParameters(RABBITMQ_HOST))
        canal = conexion.channel()

        canal.queue_declare(queue=QUEUE_NAME)

        mensaje = json.dumps(notificacion)  
        canal.basic_publish(exchange="", routing_key=QUEUE_NAME, body=mensaje)

        conexion.close()
        return {"mensaje": "Notificación encolada"}
    except Exception as e:
        return {"error": str(e)}

# Esto es solo para probarlo directamente:
if __name__ == "__main__":
    notificacion = {
        "destinatario": "juan.esteban.molina@correounivalle.edu.co",
        "asunto": "Cambio de horario",
        "cuerpo": "Su clase fue reprogramada"
    }
    print(enviar_mensaje(notificacion))
    print("📤 Mensaje encolado correctamente")
