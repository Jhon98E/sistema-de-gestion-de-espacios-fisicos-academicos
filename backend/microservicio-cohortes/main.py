from fastapi import FastAPI
from routes.cohortes_router import cohortes_route
from contextlib import asynccontextmanager
from database import Base, engine

@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine)
    yield

app = FastAPI(lifespan=lifespan)
app.title = "Microservicio Gestion de Cohortes"

app.include_router(cohortes_route)

