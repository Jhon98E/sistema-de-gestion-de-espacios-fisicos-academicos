from fastapi import HTTPException, status
from sqlalchemy.orm import Session
from models.usuario_model import UsuarioDB
from controllers.services.auth.manejador_auth import verificar_password, crear_token_acceso, decodificar_token_acceso, hash_password
from controllers.services.notificacion_service import NotificacionService
import secrets
import logging
from datetime import datetime, timedelta

# Cache simple para tokens de recuperación (en producción usar Redis)
tokens_recuperacion = {}

notificacion_service = NotificacionService()

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

async def solicitar_recuperacion_password(email: str, db: Session):
    """Solicitar recuperación de contraseña"""
    usuario_db = db.query(UsuarioDB).filter(UsuarioDB.email == email).first()
    if not usuario_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="No se encontró usuario con ese email"
        )
    
    # Generar token de recuperación
    token_recuperacion = secrets.token_urlsafe(32)
    
    # Guardar token con expiración (15 minutos)
    tokens_recuperacion[token_recuperacion] = {
        "usuario_id": usuario_db.id,
        "expiracion": datetime.now() + timedelta(minutes=15),
        "usado": False
    }
    
    # Enviar notificación de recuperación
    try:
        nombre_completo = f"{usuario_db.nombre} {usuario_db.apellido}"
        await notificacion_service.enviar_notificacion_recuperacion(
            email=usuario_db.email,
            nombre_completo=nombre_completo,
            token_recuperacion=token_recuperacion
        )
        return {"message": "Se ha enviado un correo con instrucciones para recuperar tu contraseña"}
    except Exception as e:
        logging.error(f"Error al enviar notificación de recuperación: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Error al procesar solicitud de recuperación"
        )

def restablecer_password(token: str, nueva_password: str, db: Session):
    """Restablecer contraseña usando token de recuperación"""
    if token not in tokens_recuperacion:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Token de recuperación inválido"
        )
    
    token_data = tokens_recuperacion[token]
    
    # Verificar expiración
    if datetime.now() > token_data["expiracion"]:
        del tokens_recuperacion[token]
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Token de recuperación expirado"
        )
    
    # Verificar que no se haya usado
    if token_data["usado"]:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Token de recuperación ya utilizado"
        )
    
    # Obtener usuario y actualizar contraseña
    usuario_db = db.query(UsuarioDB).filter(UsuarioDB.id == token_data["usuario_id"]).first()
    if not usuario_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Usuario no encontrado"
        )
    
    # Actualizar contraseña
    usuario_db.password = hash_password(nueva_password)
    db.commit()
    
    # Marcar token como usado
    tokens_recuperacion[token]["usado"] = True
    
    return {"message": "Contraseña restablecida exitosamente"}