from fastapi.testclient import TestClient
from ..main import app

client = TestClient(app)

def test_listar_programas():
    response = client.get("/programas")
    assert response.status_code == 200
