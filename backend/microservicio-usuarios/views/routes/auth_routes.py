from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from fastapi.security import OAuth2PasswordRequestForm
from controllers.repositories.database import get_db
from controllers import auth_controller

auth_router = APIRouter(prefix="/auth", tags=["Autenticación"])

@auth_router.post("/login")
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    return auth_controller.login_usuario(form_data.username, form_data.password, db)
