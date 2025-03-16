from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from database import get_db
from models.usuario_model import Usuario
from controllers import usuario_controller
from auth.manejador_auth import consultar_usuario_actual

usuario_router = APIRouter(prefix="/usuarios", tags=["Usuarios"])

@usuario_router.get("/", response_model=list[Usuario])
async def consultar_usuarios(db: Session = Depends(get_db), usuario_actual = Depends(consultar_usuario_actual)):
    return usuario_controller.obtener_usuarios(db)

@usuario_router.get("/{id}", response_model=Usuario)
async def consultar_usuario(id: int, db: Session = Depends(get_db), usuario_actual = Depends(consultar_usuario_actual)):
    return usuario_controller.obtener_usuario_por_id(id, db)

@usuario_router.get("/rol/{rol}", response_model=list[Usuario])
async def consultar_por_rol(rol: str, db: Session = Depends(get_db), usuario_actual = Depends(consultar_usuario_actual)):
    return usuario_controller.obtener_usuarios_por_rol(rol, db)

@usuario_router.get("/codigo/{codigo_usuario}", response_model=Usuario)
async def consultar_por_codigo(codigo_usuario: str, db: Session = Depends(get_db), usuario_actual = Depends(consultar_usuario_actual)):
    return usuario_controller.obtener_usuario_por_codigo(codigo_usuario, db)

@usuario_router.post("/crear-usuario", response_model=Usuario, status_code=201)
async def crear_usuario(usuario: Usuario, db: Session = Depends(get_db)):
    return usuario_controller.crear_usuario(usuario, db)

@usuario_router.put("/actualizar-usuario/{id}", response_model=Usuario)
async def actualizar_usuario(id: int, usuario: Usuario, db: Session = Depends(get_db), usuario_actual = Depends(consultar_usuario_actual)):
    return usuario_controller.actualizar_usuario(id, usuario, db)

@usuario_router.delete("/eliminar-usuario/{id}", status_code=200)
async def eliminar_usuario(id: int, db: Session = Depends(get_db), usuario_actual = Depends(consultar_usuario_actual)):
    return usuario_controller.eliminar_usuario(id, db)
