import aio_pika
import json
import asyncio
import os
import logging
from controllers.services.email_service import EmailService

# Configurar logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

async def procesar_notificacion(mensaje):
    """Procesar mensaje de notificación"""
    try:
        logger.info(f"📨 Procesando mensaje: {mensaje.body.decode()}")
        
        email_service = EmailService()
        data = json.loads(mensaje.body.decode())
        
        # Enviar correo
        exito = await email_service.enviar_correo(data)
        
        if exito:
            # Confirmar mensaje procesado
            await mensaje.ack()  # ← CAMBIO: await agregado
            logger.info("✅ Notificación procesada exitosamente")
        else:
            # Rechazar mensaje para reintento
            await mensaje.nack(requeue=True)  # ← CAMBIO: await agregado
            logger.error("❌ Error al procesar notificación, reintentando...")
            
    except json.JSONDecodeError as e:
        logger.error(f"❌ Error al decodificar JSON: {e}")
        await mensaje.nack(requeue=False)  # No reencolar mensaje malformado
    except Exception as e:
        logger.error(f"❌ Error al procesar mensaje: {e}")
        await mensaje.nack(requeue=True)  # ← CAMBIO: await agregado

async def iniciar_consumidor():
    """Iniciar consumidor de RabbitMQ"""
    connection = None
    max_reintentos = 5
    reintentos = 0
    
    while reintentos < max_reintentos:
        try:
            rabbitmq_url = os.getenv("RABBITMQ_URL", "amqp://guest:guest@rabbitmq:5672/")
            logger.info(f"🔗 Conectando a RabbitMQ: {rabbitmq_url}")
            
            connection = await aio_pika.connect_robust(
                rabbitmq_url,
                heartbeat=60,  # ← CAMBIO: Heartbeat para mantener conexión
                blocked_connection_timeout=300,
            )
            
            channel = await connection.channel()
            await channel.set_qos(prefetch_count=1)  # Procesar un mensaje a la vez
            
            # Declarar cola
            queue = await channel.declare_queue(
                "notificaciones_email", 
                durable=True
            )
            
            logger.info(f"📋 Cola declarada: {queue.name}, mensajes: {queue.declaration_result.message_count}")
            
            # Configurar consumidor
            await queue.consume(procesar_notificacion, no_ack=False)  # ← CAMBIO: no_ack=False explícito
            
            logger.info("🚀 Consumidor de notificaciones iniciado y esperando mensajes...")
            
            # Mantener el consumidor activo
            try:
                await asyncio.Future()  # run forever
            except asyncio.CancelledError:
                logger.info("🛑 Consumidor cancelado")
                break
                
        except aio_pika.exceptions.AMQPConnectionError as e:
            reintentos += 1
            logger.error(f"❌ Error de conexión AMQP (intento {reintentos}/{max_reintentos}): {e}")
            if reintentos < max_reintentos:
                await asyncio.sleep(5 * reintentos)  # Backoff exponencial
            
        except Exception as e:
            reintentos += 1
            logger.error(f"❌ Error en consumidor de RabbitMQ (intento {reintentos}/{max_reintentos}): {e}")
            if reintentos < max_reintentos:
                await asyncio.sleep(5)
        
        finally:
            if connection and not connection.is_closed:
                await connection.close()
    
    logger.error("❌ Se agotaron los reintentos. Consumidor terminado.")

async def main():
    """Función principal"""
    try:
        await iniciar_consumidor()
    except KeyboardInterrupt:
        logger.info("🛑 Consumidor detenido por el usuario")
    except Exception as e:
        logger.error(f"❌ Error fatal: {e}")

if __name__ == "__main__":
    asyncio.run(main())