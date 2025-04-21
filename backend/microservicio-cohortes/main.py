from fastapi import FastAPI
from routes.cohortes_router import cohortes_route

app = FastAPI()

app.include_router(cohortes_route)

