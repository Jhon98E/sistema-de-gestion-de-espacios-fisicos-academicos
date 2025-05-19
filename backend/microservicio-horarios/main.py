from fastapi import FastAPI
from contextlib import asynccontextmanager
from controllers.repositories.database import Base, engine
from views.routes import horario_routes
from views.routes import asignatura_programa_cohorte_routes


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Código de startup: aquí creamos las tablas
    Base.metadata.create_all(bind=engine)
    yield
    # Código de apagado: aquí eliminamos las tablas


app = FastAPI(lifespan=lifespan, title="Microservicio de Gestion de Horarios")

# Inicializar Rutas
app.include_router(horario_routes.horario_router)

app.include_router(asignatura_programa_cohorte_routes.router)

