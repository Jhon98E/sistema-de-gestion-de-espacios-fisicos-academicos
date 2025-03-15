from fastapi import APIRouter, HTTPException, Depends, status
from db.models.usuario_model import Usuario
from db.database import get_db
from sqlalchemy.orm import Session
from db.models.usuario_model import UsuarioDB
from auth.manejador_auth import hash_password
from auth.manejador_auth import consultar_usuario_actual


usuario = APIRouter(prefix="/usuarios", tags=["Usuarios"])


@usuario.get(path="/protegida", tags=["Usuarios - Rutas Protegidas"])
async def ruta_protegida(usuario_actual: UsuarioDB = Depends(consultar_usuario_actual)):
    return {"message":f"Hola {usuario_actual.nombre}, has accedido a una ruta protegida"}


# Retorna Todos los Usuarios registrados.
@usuario.get(path="/")
async def consultar_usuarios(usuario_actual: UsuarioDB = Depends(consultar_usuario_actual), db: Session = Depends(dependency=get_db)):
    return db.query(UsuarioDB).all()


# Retorna solo un usuario al buscarlo por su "id".
@usuario.get(path="/{id}")
async def consultar_usuario(id: int, db: Session = Depends(dependency=get_db), usuario_actual: UsuarioDB = Depends(consultar_usuario_actual)) -> Usuario:
    usuario = db.query(UsuarioDB).filter(UsuarioDB.id == id).first()

    if usuario:
        return usuario
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario con ID {id} no fue encontrado")


# Retorna todos los usuarios que coincidan con el "rol" especificado.
@usuario.get(path="/rol/{rol}")
async def consultar_por_rol(rol: str, db: Session = Depends(dependency=get_db), usuario_actual: UsuarioDB = Depends(consultar_usuario_actual)):
    usuario = db.query(UsuarioDB).filter(UsuarioDB.rol == rol).all()

    if usuario:
        return usuario
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario no encontrado")


# Retorna el usuario que coincida con el "codigo de Estudiante o Empleado" especificado.
@usuario.get(path="/codigo/{codigo_usuario}")
async def consultar_por_codigo(codigo_usuario: str, db: Session = Depends(dependency=get_db), usuario_actual: UsuarioDB = Depends(consultar_usuario_actual)):
    usuario = db.query(UsuarioDB).filter(UsuarioDB.codigo_usuario == codigo_usuario).first()

    if usuario:
        return usuario
    raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario con ID {codigo_usuario} no fue encontrado")


# Crear un Usuario
@usuario.post(path="/crear-usuario", status_code=status.HTTP_201_CREATED)
async def crear_usuario(usuario: Usuario, db: Session = Depends(dependency=get_db)):
    codigo_existente = db.query(UsuarioDB).filter(UsuarioDB.codigo_usuario == usuario.codigo_usuario).first()
    email_existente = db.query(UsuarioDB).filter(UsuarioDB.email == usuario.email).first()
    if codigo_existente or email_existente:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="El usuario con ese email o código ya existe")
    
    nuevo_usuario = UsuarioDB(
        nombre=usuario.nombre,
        apellido=usuario.apellido,
        codigo_usuario=usuario.codigo_usuario,
        rol=usuario.rol,
        email=usuario.email,
        password=hash_password(usuario.password)
    )
    db.add(nuevo_usuario)
    db.commit()
    db.refresh(nuevo_usuario)
    return nuevo_usuario


# Actualizar Usuario
@usuario.put(path='/actualizar-usuario/{id}')
async def actualizar_usuario(id: int, usuario: Usuario, db: Session = Depends(dependency=get_db), usuario_actual: UsuarioDB = Depends(consultar_usuario_actual)):
    usuario_db = db.query(UsuarioDB).filter(UsuarioDB.id == id).first()

    if not usuario_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario con ID {id} no fue encontrado")
    
    usuario_db.nombre = usuario.nombre
    usuario_db.apellido = usuario.apellido
    usuario_db.codigo_usuario = usuario.codigo_usuario
    usuario_db.rol = usuario.rol
    usuario_db.email = usuario.email
    usuario_db.password = usuario.password

    db.commit()
    db.refresh(usuario_db)

    return usuario_db


# Eliminar Usuarios
@usuario.delete(path='/eliminar-usuario/{id}', status_code=status.HTTP_204_NO_CONTENT)
async def eliminar_usuario(id: int, db: Session = Depends(dependency=get_db), usuario_actual: UsuarioDB = Depends(consultar_usuario_actual)):
    usuario_db = db.query(UsuarioDB).filter(UsuarioDB.id == id).first()

    if not usuario_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario con ID {id} no fue encontrado")
    
    db.delete(usuario_db)
    db.commit()

    return {"message": "Usuario Eliminado Exitosamente", "usuario": usuario_db}
