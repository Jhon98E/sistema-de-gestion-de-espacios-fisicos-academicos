from fastapi import FastAPI
from routes import asignatura_router
from contextlib import asynccontextmanager
from database import Base, engine

@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield

app = FastAPI(lifespan=lifespan)
app.title = "Microservicio Gestion de Asignaturas"


app.include_router(asignatura_router.asignatura_router)