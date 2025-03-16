from fastapi import FastAPI
from app.routes import programa_routes  # Importa las rutas de programas
from app.database import Base, engine
Base.metadata.create_all(bind=engine)

app = FastAPI()

# Incluir las rutas
app.include_router(programa_routes.router)

@app.get("/")
def home():
    return {"message": "Microservicio de Programas en funcionamiento"}
