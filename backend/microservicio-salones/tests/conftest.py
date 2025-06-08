import pytest
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from controllers.repositories.database import Base, get_db
from fastapi.testclient import TestClient
from main import app
from controllers.services.auth.auth_service import obtener_usuario_actual

# Base de datos en memoria para pruebas
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Fixture para la base de datos de pruebas
@pytest.fixture(scope="function")
def db_session():
    Base.metadata.create_all(bind=engine)  # Crea las tablas antes de cada prueba
    session = TestingSessionLocal()
    yield session  # Retorna la sesión para su uso en pruebas
    session.close()
    Base.metadata.drop_all(bind=engine)  # Limpia la base de datos después de cada prueba

# Mock para el usuario autenticado
async def mock_usuario_actual():
    return {
        "user_id": 1,
        "codigo_usuario": "2260647",
        "rol": "admin",
        "email": "test@test.com",
        "nombre_completo": "Usuario Test"
    }

# Fixture para el cliente de pruebas
@pytest.fixture(scope="function")
def client(db_session):
    def override_get_db():
        yield db_session
    
    # Sobreescribimos la dependencia de autenticación
    app.dependency_overrides[get_db] = override_get_db
    app.dependency_overrides[obtener_usuario_actual] = mock_usuario_actual
    
    yield TestClient(app)
    
    # Limpiamos las dependencias después de las pruebas
    app.dependency_overrides.clear()
