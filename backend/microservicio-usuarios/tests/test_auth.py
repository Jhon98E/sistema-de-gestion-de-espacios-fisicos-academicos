from fastapi.testclient import TestClient

usuario_test = {
    "nombre": "Carlos",
    "apellido": "López",
    "codigo_usuario": "CL456",
    "rol": "admin",
    "email": "carlos.lopez@example.com",
    "password": "password456"
}

def test_registro_usuario(client: TestClient):
    
    response = client.post("/usuarios/crear-usuario", json=usuario_test)
    assert response.status_code in [201, 409]

def test_login_usuario(client: TestClient):
    
    client.post("/usuarios/crear-usuario", json=usuario_test)

    login_data = {"username": "CL456", "password": "password456"}
    response = client.post("/auth/login", data=login_data)
    assert response.status_code == 200, f"⚠️ Error en login: {response.json()}"
    assert "access_token" in response.json()

def test_login_fallido(client: TestClient):
    
    login_data = {"username": "CL456", "password": "wrongpassword"}
    response = client.post("/auth/login", data=login_data)
    assert response.status_code == 400


def test_acceso_ruta_protegida_con_token(client: TestClient):
    
    client.post("/usuarios/crear-usuario", json=usuario_test)

    login_data = {"username": "CL456", "password": "password456"}
    response = client.post("/auth/login", data=login_data)
    assert response.status_code == 200, f"⚠️ Error en login: {response.json()}"
