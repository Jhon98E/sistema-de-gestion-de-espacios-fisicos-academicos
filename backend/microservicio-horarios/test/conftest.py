import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from unittest.mock import patch

from main import app
from controllers.repositories.database import Base, get_db
from controllers.services.auth.auth_service import obtener_usuario_actual

# Mock del usuario autenticado para pruebas
async def mock_usuario_actual():
    return {
        "user_id": 1,
        "codigo_usuario": "2260647",
        "rol": "admin",
        "email": "test@test.com",
        "nombre_completo": "Usuario Test"
    }

# Base de datos en memoria para pruebas
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

@pytest.fixture(scope="function")
def db_session():
    Base.metadata.create_all(bind=engine)
    session = TestingSessionLocal()
    try:
        yield session
    finally:
        session.close()
        Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def client(db_session):
    def override_get_db():
        try:
            yield db_session
        finally:
            pass
    
    # Sobreescribimos las dependencias
    app.dependency_overrides[get_db] = override_get_db
    app.dependency_overrides[obtener_usuario_actual] = mock_usuario_actual
    
    # Mock para el servicio de notificaciones
    with patch('controllers.services.notificacion_service.NotificacionService.enviar_notificacion_horario') as mock_notif:
        mock_notif.return_value = True
        yield TestClient(app)
    
    app.dependency_overrides.clear()