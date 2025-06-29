from fastapi import FastAPI
from views.routes import asignatura_router
from contextlib import asynccontextmanager
from controllers.repositories.database import Base, engine

@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine, checkfirst=True)
    yield

app = FastAPI(lifespan=lifespan)
app.title = "Microservicio Gestion de Asignaturas"


app.include_router(asignatura_router.asignatura_router)