import pika
import json
from notificacion_service import enviar_correo

def callback(ch, method, properties, body):
    print(f"📩 Mensaje recibido: {body}")
    notificacion = json.loads(body)
    enviar_correo(notificacion)
    ch.basic_ack(delivery_tag=method.delivery_tag)

def consumir_mensajes():
    connection = pika.BlockingConnection(pika.ConnectionParameters("localhost"))
    channel = connection.channel()
    channel.queue_declare(queue="cola_notificaciones")
    channel.basic_consume(queue="cola_notificaciones", on_message_callback=callback)
    print("🐰 Esperando mensajes...")
    channel.start_consuming()

if __name__ == "__main__":
    consumir_mensajes()
