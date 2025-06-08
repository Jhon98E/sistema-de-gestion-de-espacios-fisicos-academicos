from fastapi import FastAPI
from views.routes.cohortes_router import cohortes_route
from contextlib import asynccontextmanager
from controllers.repositories.database import Base, engine

@asynccontextmanager
async def lifespan(app: FastAPI):
    Base.metadata.create_all(bind=engine, checkfirst=True)
    yield

app = FastAPI(lifespan=lifespan)
app.title = "Microservicio Gestion de Cohortes"

app.include_router(cohortes_route)
