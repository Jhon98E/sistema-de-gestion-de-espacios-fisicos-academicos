from fastapi import FastAPI
from contextlib import asynccontextmanager
from views.routes.notificacion_routes import router as notificacion_router
from controllers.services.rabbitmq_consumer import iniciar_consumidor
import asyncio

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Iniciar el consumidor de RabbitMQ en segundo plano
    consumer_task = asyncio.create_task(iniciar_consumidor())
    yield
    # Cancelar el consumidor al cerrar la aplicación
    consumer_task.cancel()
    try:
        await consumer_task
    except asyncio.CancelledError:
        pass

app = FastAPI(
    title="Microservicio de Notificaciones", 
    version="1.0",
    lifespan=lifespan
)

app.include_router(notificacion_router)
