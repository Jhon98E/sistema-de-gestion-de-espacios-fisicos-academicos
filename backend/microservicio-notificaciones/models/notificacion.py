from pydantic import BaseModel

class Notificacion(BaseModel):
    destinatario: str
    asunto: str
    mensaje: str
    estado: str = "Pendiente"
