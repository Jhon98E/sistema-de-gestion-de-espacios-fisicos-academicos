from fastapi.testclient import TestClient
from models.schemas.programa_schemas import Programa # noqa: F401
from main import app

def test_crear_programa(client: TestClient):
    response = client.post("/programas/", json={
        "nombre": "Ingeniería de Software",
        "descripcion": "Programa de Ingeniería",
        "codigo_programa": "9999"
    })
    assert response.status_code == 200
    assert response.json()["nombre"] == "Ingeniería de Software"
    assert response.json()["codigo_programa"] == "9999"

def test_obtener_programas(client: TestClient):
    # Crear un programa de prueba primero
    client.post("/programas/", json={
        "nombre": "Programa de Prueba",
        "descripcion": "Descripción de prueba",
        "codigo_programa": "1111"
    })
    
    response = client.get("/programas/")
    assert response.status_code == 200
    assert isinstance(response.json(), list)
    assert len(response.json()) > 0

def test_obtener_programa(client: TestClient):
    # Crear un programa
    response = client.post("/programas/", json={
        "nombre": "Ingeniería Civil",
        "descripcion": "Programa de Ingeniería Civil",
        "codigo_programa": "8888"
    })
    program_id = response.json()["id"]
    
    response = client.get(f"/programas/{program_id}")
    assert response.status_code == 200
    assert response.json()["nombre"] == "Ingeniería Civil"
    assert response.json()["codigo_programa"] == "8888"

def test_actualizar_programa(client: TestClient):
    # Crear programa
    response = client.post("/programas/", json={
        "nombre": "Arquitectura",
        "descripcion": "Programa de Arquitectura",
        "codigo_programa": "7777"
    })
    program_id = response.json()["id"]
    
    # Actualizar
    response = client.put(f"/programas/{program_id}", json={
        "nombre": "Arquitectura y Urbanismo",
        "descripcion": "Programa actualizado",
        "codigo_programa": "7777"
    })
    assert response.status_code == 200
    assert response.json()["nombre"] == "Arquitectura y Urbanismo"

def test_eliminar_programa(client: TestClient):
    # Crear programa
    response = client.post("/programas/", json={
        "nombre": "Diseño Gráfico",
        "descripcion": "Programa de Diseño",
        "codigo_programa": "6666"
    })
    program_id = response.json()["id"]
    
    # Eliminar
    response = client.delete(f"/programas/{program_id}")
    assert response.status_code == 200
    
    # Verificar eliminación
    response = client.get(f"/programas/{program_id}")
    assert response.status_code == 404

def test_acceso_no_autorizado(client):
    # Temporalmente quitamos el mock de autenticación
    app.dependency_overrides.clear()
    
    response = client.get("/programas/")
    assert response.status_code == 401
    assert response.json()["detail"] == "Not authenticated"

def test_codigo_programa_duplicado(client):
    # Crear primer programa
    response = client.post("/programas/", json={
        "nombre": "Programa 1",
        "descripcion": "Descripción 1",
        "codigo_programa": "5555"
    })
    assert response.status_code == 200
    
    # Intentar crear programa con código duplicado
    response = client.post("/programas/", json={
        "nombre": "Programa 2",
        "descripcion": "Descripción 2",
        "codigo_programa": "5555"
    })
    assert response.status_code == 409
    assert "Ya existe un programa con este codigo de programa" in response.json()["detail"]
