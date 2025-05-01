from fastapi import FastAPI
from routes import programa_routes  
from contextlib import asynccontextmanager
from database import Base, engine


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Código de startup: aquí creamos las tablas
    Base.metadata.create_all(bind=engine)
    yield
    # Código de apagado: aquí eliminamos las tablas

app = FastAPI(lifespan=lifespan, title="Microservicio de Programas academicos")

# Incluir las rutas
app.include_router(programa_routes.router)

@app.get("/")
def home():
    return {"message": "Microservicio de Programas en funcionamiento"}
