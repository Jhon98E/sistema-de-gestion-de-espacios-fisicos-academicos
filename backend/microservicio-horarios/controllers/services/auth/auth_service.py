import httpx
import os
from fastapi import HTTPException, status, Depends
from fastapi.security import OAuth2PasswordBearer
import logging

logging.basicConfig(level=logging.INFO)

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

class AuthService:
    def __init__(self):
        self.usuarios_service_url = os.getenv("USUARIOS_SERVICE_URL", "http://localhost:8000")
        self.timeout = 10.0
    
    async def validar_token(self, token: str) -> dict:
        """
        Valida un token JWT consultando al microservicio de usuarios
        Retorna la información del usuario si el token es válido
        """
        try:
            url = f"{self.usuarios_service_url}/auth/validar-token"
            headers = {"Authorization": f"Bearer {token}"}
            
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(url, headers=headers)
            
            if response.status_code == 200:
                user_data = response.json()
                logging.info(f"✅ Token válido para usuario: {user_data.get('codigo_usuario')}")
                return user_data
            elif response.status_code == 401:
                logging.warning("⚠️ Token inválido o expirado")
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail="Token inválido o expirado",
                    headers={"WWW-Authenticate": "Bearer"}
                )
            else:
                logging.error(f"❌ Error inesperado del servicio de usuarios: {response.status_code}")
                raise HTTPException(
                    status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                    detail="Servicio de autenticación no disponible"
                )
                
        except httpx.TimeoutException:
            logging.error("❌ Timeout al conectar con el servicio de usuarios")
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Servicio de autenticación no disponible"
            )
        except httpx.RequestError as e:
            logging.error(f"❌ Error de conexión con el servicio de usuarios: {e}")
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Servicio de autenticación no disponible"
            )

# Instancia global del servicio de autenticación
auth_service = AuthService()

async def obtener_usuario_actual(token: str = Depends(oauth2_scheme)) -> dict:
    """
    Dependency que obtiene y valida el usuario actual desde el token JWT
    """
    return await auth_service.validar_token(token)

async def verificar_admin(usuario_actual: dict = Depends(obtener_usuario_actual)) -> dict:
    """
    Dependency que verifica si el usuario actual tiene rol de administrador
    """
    if usuario_actual.get("rol") != "admin":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No tienes permisos de administrador para realizar esta acción"
        )
    return usuario_actual

async def verificar_admin_o_docente(usuario_actual: dict = Depends(obtener_usuario_actual)) -> dict:
    """
    Dependency que verifica si el usuario actual es admin o docente
    """
    rol = usuario_actual.get("rol")
    if rol not in ["admin", "docente"]:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="No tienes permisos para realizar esta acción. Requiere rol de admin o docente"
        )
    return usuario_actual