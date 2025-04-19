from fastapi import FastAPI
from routes import asignatura_router


app = FastAPI()
app.title = "Microservicio Gestion de Asignaturas"


app.include_router(asignatura_router.asignatura_router)