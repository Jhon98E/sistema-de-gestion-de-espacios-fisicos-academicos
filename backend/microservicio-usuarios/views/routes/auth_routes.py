from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordRequestForm
from pydantic import BaseModel, EmailStr
from controllers.repositories.database import get_db
from controllers import auth_controller
from controllers.services.auth.manejador_auth import consultar_usuario_actual, oauth2_scheme

auth_router = APIRouter(prefix="/auth", tags=["Autenticación"])

class SolicitudRecuperacion(BaseModel):
    email: EmailStr

class RestablecerPassword(BaseModel):
    token: str
    nueva_password: str

@auth_router.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    return auth_controller.login_usuario(form_data.username, form_data.password, db)

@auth_router.post("/logout")
async def logout(token: str = Depends(oauth2_scheme), usuario_actual = Depends(consultar_usuario_actual)):
    """
    Endpoint para cerrar sesión del usuario.
    En una implementación básica, simplemente confirmamos que el token es válido.
    """
    return {"message": "Sesión cerrada exitosamente", "usuario": usuario_actual.codigo_usuario}

@auth_router.post("/validate-token")
async def validate_token(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    """
    Endpoint para validar tokens desde otros microservicios.
    Retorna información del usuario si el token es válido.
    """
    try:
        usuario_actual = auth_controller.validar_token_para_microservicios(token, db)
        return {
            "valid": True,
            "user_id": usuario_actual.id,
            "codigo_usuario": usuario_actual.codigo_usuario,
            "rol": usuario_actual.rol,
            "email": usuario_actual.email,
            "nombre_completo": f"{usuario_actual.nombre} {usuario_actual.apellido}"
        }
    except HTTPException as e:
        raise e
    except Exception:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Token inválido",
            headers={"WWW-Authenticate": "Bearer"}
        )

@auth_router.post("/solicitar-recuperacion")
async def solicitar_recuperacion(solicitud: SolicitudRecuperacion, db: Session = Depends(get_db)):
    """
    Endpoint para solicitar recuperación de contraseña.
    Envía un email con el token de recuperación.
    """
    return await auth_controller.solicitar_recuperacion_password(solicitud.email, db)

@auth_router.post("/restablecer-password")
async def restablecer_password(datos: RestablecerPassword, db: Session = Depends(get_db)):
    """
    Endpoint para restablecer contraseña usando el token de recuperación.
    """
    return auth_controller.restablecer_password(datos.token, datos.nueva_password, db)