from fastapi import FastAPI
from contextlib import asynccontextmanager
from database import Base, engine
from routes import horario_routes


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Código de startup: aquí creamos las tablas
    Base.metadata.create_all(bind=engine)
    yield
    # Código de apagado: aquí eliminamos las tablas


app = FastAPI(lifespan=lifespan, title="Microservicio de Gestion de Horarios")

# Inicializar Rutas
app.include_router(horario_routes.horario_router)
app.include_router(horario_routes.horario_router)
