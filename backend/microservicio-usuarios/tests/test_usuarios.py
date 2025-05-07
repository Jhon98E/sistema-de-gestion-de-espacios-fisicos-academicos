import pytest
from fastapi.testclient import TestClient

# Datos de prueba
usuario_test = {
    "nombre": "Juan",
    "apellido": "Pérez",
    "codigo_usuario": "JP123",
    "rol": "admin",
    "email": "juan.perez@example.com",
    "password": "password123"
}


@pytest.fixture
def auth_token(client: TestClient):
    
    client.post("/usuarios/crear-usuario", json=usuario_test)
    
    login_data = {"username": "JP123", "password": "password123"}
    response = client.post("/auth/login", data=login_data)
    assert response.status_code == 200, f"Error en login: {response.json()}"
    return response.json()["access_token"]


def test_crear_usuario(client: TestClient):
    
    response = client.post("/usuarios/crear-usuario", json=usuario_test)
    assert response.status_code in [201, 409]  # 409 si ya existe
    if response.status_code == 201:
        assert response.json()["nombre"] == "Juan"


def test_consultar_usuarios(client: TestClient, auth_token):
    
    headers = {"Authorization": f"Bearer {auth_token}"}
    response = client.get("/usuarios/", headers=headers)
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_consultar_usuario_por_id(client: TestClient, auth_token):
    
    headers = {"Authorization": f"Bearer {auth_token}"}
    
    response = client.get(f"/usuarios/codigo/{usuario_test['codigo_usuario']}", headers=headers)
    assert response.status_code == 200
    usuario = response.json()
    usuario_id = usuario["id"]

    response = client.get(f"/usuarios/{usuario_id}", headers=headers)
    assert response.status_code == 200
    assert response.json()["codigo_usuario"] == "JP123"


def test_consultar_usuario_por_rol(client: TestClient, auth_token):
    
    headers = {"Authorization": f"Bearer {auth_token}"}
    response = client.get("/usuarios/rol/admin", headers=headers)
    assert response.status_code == 200
    assert isinstance(response.json(), list)


def test_actualizar_usuario(client: TestClient, auth_token):
    
    headers = {"Authorization": f"Bearer {auth_token}"}

    response = client.get(f"/usuarios/codigo/{usuario_test['codigo_usuario']}", headers=headers)
    usuario_id = response.json()["id"]

    nuevo_dato = usuario_test.copy()
    nuevo_dato["nombre"] = "Juan Modificado"

    response = client.put(f"/usuarios/actualizar-usuario/{usuario_id}", json=nuevo_dato, headers=headers)
    assert response.status_code == 200
    assert response.json()["nombre"] == "Juan Modificado"


def test_eliminar_usuario(client: TestClient, auth_token):
    
    headers = {"Authorization": f"Bearer {auth_token}"}

    # Obtener ID del usuario
    response = client.get(f"/usuarios/codigo/{usuario_test['codigo_usuario']}", headers=headers)
    usuario_id = response.json().get("id")
    assert usuario_id, "⚠️ No se encontró el ID del usuario"

    # Crear usuario administrador si no existe
    admin_usuario = {
        "nombre": "Admin",
        "apellido": "Root",
        "codigo_usuario": "admin",
        "rol": "admin",
        "email": "admin@example.com",
        "password": "admin123"
    }
    client.post("/usuarios/crear-usuario", json=admin_usuario)

    # Iniciar sesión como administrador para eliminar usuarios
    admin_login_data = {"username": "admin", "password": "admin123"}
    response = client.post("/auth/login", data=admin_login_data)
    assert response.status_code == 200, f"Error al iniciar sesión como admin: {response.json()}"
    
    admin_token = response.json()["access_token"]
    admin_headers = {"Authorization": f"Bearer {admin_token}"}

    # Eliminar usuario con permisos de administrador
    response = client.delete(f"/usuarios/eliminar-usuario/{usuario_id}", headers=admin_headers)
    assert response.status_code == 200, f"Error al eliminar usuario: {response.json()}"

    # Verificar que el usuario fue eliminado
    response = client.get(f"/usuarios/{usuario_id}", headers=admin_headers)
    assert response.status_code == 404  # Usuario ya no debería existir
