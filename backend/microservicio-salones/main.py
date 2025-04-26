from fastapi import FastAPI
from routes import salones_routes
from database import Base, engine
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan (app:FastAPI):
    Base.metadata.create_all(bind=engine)
    yield

app=FastAPI(lifespan=lifespan, title= "Microservicio Gestion de Salones")

app.include_router(salones_routes.salon_router)