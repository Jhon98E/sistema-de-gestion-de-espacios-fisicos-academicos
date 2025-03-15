from fastapi import FastAPI
from contextlib import asynccontextmanager
from db.database import Base, engine
from routes import usuarios_routes
from routes import auth_routes


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Código de startup: aquí creamos las tablas
    Base.metadata.create_all(bind=engine)
    yield
    # Código de apagado: aquí eliminamos las tablas


app = FastAPI(lifespan=lifespan)
app.title = "Microservicio de Gestion de Usuarios y Autenticación"

# Inicializar Rutas
app.include_router(router=usuarios_routes.usuario)
app.include_router(router=auth_routes.auth_router)