from fastapi import FastAPI
from views.routes import programa_routes  
from contextlib import asynccontextmanager
from controllers.repositories.database import Base, engine


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Código de startup: aquí creamos las tablas
    Base.metadata.create_all(bind=engine, checkfirst=True)
    yield
    # Código de apagado: aquí eliminamos las tablas

app = FastAPI(lifespan=lifespan, title="Microservicio de Programas academicos")

# Incluir las rutas
app.include_router(programa_routes.router)