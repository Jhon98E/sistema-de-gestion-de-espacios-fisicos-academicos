from fastapi import FastAPI
from routes import programa_routes  
from database import Base, engine
Base.metadata.create_all(bind=engine)

app = FastAPI()

# Incluir las rutas
app.include_router(programa_routes.router)

@app.get("/")
def home():
    return {"message": "Microservicio de Programas en funcionamiento"}
