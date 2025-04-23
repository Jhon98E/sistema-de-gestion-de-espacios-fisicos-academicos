from fastapi import FastAPI
from controllers.notificacion_controller import router as notificacion_router

app = FastAPI(title="Microservicio de Notificaciones", version="1.0")

app.include_router(notificacion_router)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

