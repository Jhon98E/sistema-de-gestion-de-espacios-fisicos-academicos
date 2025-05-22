from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from models.usuario_model import UsuarioDB
from controllers.services.auth.manejador_auth import verificar_password, crear_token_acceso, decodificar_token_acceso

def login_usuario(codigo_usuario: str, password: str, db: Session):
    usuario_db = db.query(UsuarioDB).filter(UsuarioDB.codigo_usuario == codigo_usuario).first()
    if not usuario_db or not verificar_password(password, usuario_db.password):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Credenciales inválidas")
    
    token = crear_token_acceso(datos={"sub": str(usuario_db.id)})
    return {"access_token": token, "token_type": "bearer"}

def validar_token_para_microservicios(token: str, db: Session):
    """
    Función para validar tokens desde otros microservicios.
    Retorna el usuario si el token es válido, de lo contrario lanza excepción.
    """
    payload = decodificar_token_acceso(token)
    
    if isinstance(payload, HTTPException):
        raise payload
    
    usuario_id = payload.get("sub")
    if usuario_id is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido - no se encontró ID de usuario",
            headers={"WWW-Authenticate": "Bearer"}
        )
    
    usuario_db = db.query(UsuarioDB).filter(UsuarioDB.id == int(usuario_id)).first()
    if not usuario_db:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Usuario no encontrado",
            headers={"WWW-Authenticate": "Bearer"}
        )
    
    return usuario_db