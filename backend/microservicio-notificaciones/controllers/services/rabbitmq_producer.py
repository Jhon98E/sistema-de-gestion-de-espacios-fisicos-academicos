import aio_pika
import json
import os
import logging
from typing import Dict, Any

async def enviar_mensaje_rabbitmq(mensaje: Dict[str, Any]):
    """Enviar mensaje a RabbitMQ"""
    try:
        rabbitmq_url = os.getenv("RABBITMQ_URL", "amqp://guest:guest@rabbitmq:5672/")
        
        connection = await aio_pika.connect_robust(rabbitmq_url)
        
        async with connection:
            channel = await connection.channel()
            
            # Declarar cola de notificaciones
            queue = await channel.declare_queue(
                "notificaciones_email", 
                durable=True
            )
            
            # Publicar mensaje
            await channel.default_exchange.publish(
                aio_pika.Message(
                    json.dumps(mensaje).encode(),
                    delivery_mode=aio_pika.DeliveryMode.PERSISTENT
                ),
                routing_key="notificaciones_email"
            )
            
        logging.info("✅ Mensaje enviado a RabbitMQ")
        
    except Exception as e:
        logging.error(f"❌ Error al enviar mensaje a RabbitMQ: {e}")
        raise