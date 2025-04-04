from fastapi import FastAPI
from routes.salones_routes import salon_router

app=FastAPI()

app.include_router(salon_router)