from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from models.usuario_model import UsuarioDB
from controllers.services.auth.manejador_auth import verificar_password, crear_token_acceso

def login_usuario(codigo_usuario: str, password: str, db: Session):
    usuario_db = db.query(UsuarioDB).filter(UsuarioDB.codigo_usuario == codigo_usuario).first()
    if not usuario_db or not verificar_password(password, usuario_db.password):
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Credenciales inválidas")
    
    token = crear_token_acceso(datos={"sub": str(usuario_db.id)})
    return {"access_token": token, "token_type": "bearer"}
