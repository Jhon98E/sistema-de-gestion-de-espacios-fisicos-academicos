from fastapi import FastAPI
from contextlib import asynccontextmanager
from controllers.repositories.database import Base, engine
from views.routes import usuario_routes, auth_routes


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Código de startup: aquí creamos las tablas
    Base.metadata.create_all(bind=engine)
    yield
    # Código de apagado: aquí eliminamos las tablas


app = FastAPI(lifespan=lifespan, title="Microservicio de Gestion de Usuarios y Autenticación")

# Inicializar Rutas
app.include_router(usuario_routes.usuario_router)
app.include_router(auth_routes.auth_router)





