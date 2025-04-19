from sqlalchemy.orm import Session
from models.usuario_model import Usuario, UsuarioDB
from fastapi import HTTPException, status
from auth.manejador_auth import hash_password

def obtener_usuarios(db: Session):
    return db.query(UsuarioDB).all()

def obtener_usuario_por_id(id: int, db: Session):
    usuario = db.query(UsuarioDB).filter(UsuarioDB.id == id).first()
    if not usuario:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario con ID {id} no fue encontrado")
    return usuario

def obtener_usuarios_por_rol(rol: str, db: Session):
    usuarios = db.query(UsuarioDB).filter(UsuarioDB.rol == rol).all()
    if not usuarios:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"No se encontraron usuarios con el rol {rol}")
    return usuarios

def obtener_usuario_por_codigo(codigo_usuario: str, db: Session):
    usuario = db.query(UsuarioDB).filter(UsuarioDB.codigo_usuario == codigo_usuario).first()
    if not usuario:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario con código {codigo_usuario} no fue encontrado")
    return usuario

def crear_usuario(data: Usuario, db: Session):
    # Verificar duplicados
    if db.query(UsuarioDB).filter(UsuarioDB.codigo_usuario == data.codigo_usuario).first() or \
       db.query(UsuarioDB).filter(UsuarioDB.email == data.email).first():
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="El usuario con ese email o código ya existe")
    
    nuevo_usuario = UsuarioDB(
        nombre=data.nombre,
        apellido=data.apellido,
        codigo_usuario=data.codigo_usuario,
        rol=data.rol,
        email=data.email,
        password=hash_password(data.password)
    )
    db.add(nuevo_usuario)
    db.commit()
    db.refresh(nuevo_usuario)
    return nuevo_usuario

def actualizar_usuario(id: int, data: Usuario, db: Session):
    usuario_db = db.query(UsuarioDB).filter(UsuarioDB.id == id).first()
    if not usuario_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario con ID {id} no fue encontrado")
    
    usuario_db.nombre = data.nombre
    usuario_db.apellido = data.apellido
    usuario_db.codigo_usuario = data.codigo_usuario
    usuario_db.rol = data.rol
    usuario_db.email = data.email
    # Aplicar hash en la nueva contraseña
    usuario_db.password = hash_password(data.password)
    
    db.commit()
    db.refresh(usuario_db)
    return usuario_db

def eliminar_usuario(id: int, db: Session):
    usuario_db = db.query(UsuarioDB).filter(UsuarioDB.id == id).first()
    if not usuario_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=f"Usuario con ID {id} no fue encontrado")
    
    db.delete(usuario_db)
    db.commit()
    return {"message": "Usuario eliminado exitosamente"}
