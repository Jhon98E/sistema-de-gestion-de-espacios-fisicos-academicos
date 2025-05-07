from fastapi import HTTPException, status, Depends
import jwt
from datetime import datetime, timedelta, timezone
from passlib.context import CryptContext
from fastapi.security import OAuth2PasswordBearer
from controllers.repositories.database import get_db
from sqlalchemy.orm import Session
from models.usuario_model import UsuarioDB


SECRET_KEY = "TU_SECRETO_SUPER_SEGURO"
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30


pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/auth/login")

def hash_password(password):
    return pwd_context.hash(password)

def verificar_password(password, hashed_password):
    return pwd_context.verify(password, hashed_password)

def crear_token_acceso(datos: dict):
    codificar = datos.copy()
    expirar = datetime.now(timezone.utc) + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    codificar.update({"exp": expirar})
    codificar_jwt = jwt.encode(payload=codificar, key=SECRET_KEY, algorithm=ALGORITHM)
    return codificar_jwt

def decodificar_token_acceso(token: str):
    try:
        payload = jwt.decode(jwt=token, key=SECRET_KEY, algorithms=[ALGORITHM])
        return payload
    except (jwt.ExpiredSignatureError, jwt.PyJWKError):
        return HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED, 
                detail="Credenciales de autenticación Invalidas",
                headers={"WWW-Authenticate": "Bearer"}
            )
    
def consultar_usuario_actual(token: str = Depends(oauth2_scheme), db: Session = Depends(dependency=get_db)):
    excepcion_credenciales = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED, 
        detail="No se pudo validar el token", 
        headers={"WWW-Authenticate": "Bearer"}
    )

    payload = decodificar_token_acceso(token)
    if payload is None:
        raise excepcion_credenciales
    
    usuario_id = payload.get("sub")
    if usuario_id is None:
        raise excepcion_credenciales
    
    usuario_db = db.query(UsuarioDB).filter(UsuarioDB.id == usuario_id).first()
    if not usuario_db:
        raise excepcion_credenciales
    
    return usuario_db