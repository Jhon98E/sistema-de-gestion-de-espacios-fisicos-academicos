import pika
import json
from services.notificacion_service import enviar_correo
from services.rabbitmq_consumer import consumir_mensajes

RABBITMQ_HOST = "localhost"
QUEUE_NAME = "notificaciones"

def callback(ch, method, properties, body):
    notificacion = json.loads(body)
    
    if "destinatario" in notificacion:
        print(f"📧 Enviando correo a {notificacion['destinatario']}")
        respuesta = enviar_correo(notificacion["destinatario"], notificacion["asunto"], notificacion["mensaje"])
        print(respuesta)

    if "token" in notificacion:
        print(f"📲 Enviando push a {notificacion['token']}")
        respuesta = consumir_mensajes(notificacion["token"], notificacion["asunto"], notificacion["mensaje"])
        print(respuesta)

    ch.basic_ack(delivery_tag=method.delivery_tag)

# Configurar conexión con RabbitMQ
conexion = pika.BlockingConnection(pika.ConnectionParameters(RABBITMQ_HOST))
canal = conexion.channel()

canal.queue_declare(queue=QUEUE_NAME, durable=True)
canal.basic_consume(queue=QUEUE_NAME, on_message_callback=callback)

print(" [*] Esperando notificaciones. Para salir, presiona CTRL+C")
canal.start_consuming()
