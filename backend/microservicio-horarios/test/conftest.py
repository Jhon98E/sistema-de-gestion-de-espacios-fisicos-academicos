import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from unittest.mock import patch
import os

from main import app
from controllers.repositories.database import Base, get_db

# Deshabilitar las llamadas HTTP durante las pruebas
os.environ["PYTEST_RUNNING"] = "true"

# 🔧 Crear base de datos en memoria
SQLALCHEMY_DATABASE_URL = "sqlite:///./test.db"  # También puedes usar "sqlite:///:memory:"
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# 🧪 Fixture para la DB y el cliente
@pytest.fixture(scope="function")
def db_session():
    Base.metadata.create_all(bind=engine)
    db = TestingSessionLocal()
    try:
        yield db
    finally:
        db.close()
        Base.metadata.drop_all(bind=engine)

@pytest.fixture(scope="function")
def client(db_session):
    # Parchear las llamadas HTTP externas
    with patch("httpx.AsyncClient"):
        def override_get_db():
            try:
                yield db_session
            finally:
                pass
        app.dependency_overrides[get_db] = override_get_db
        yield TestClient(app)