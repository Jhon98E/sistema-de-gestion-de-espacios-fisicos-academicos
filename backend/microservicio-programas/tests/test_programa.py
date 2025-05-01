# test_programa.py
from fastapi.testclient import TestClient
from main import app  # Asume que tu aplicación está en el archivo main.py
from schemas.programa_schemas import Programa 

def test_crear_programa(client: TestClient):
    response = client.post("/programas/", json={
        "nombre": "Ingeniería de Software",
        "codigo_programa": "9999"
    })
    assert response.status_code == 200  # Esperamos un status code 200
    assert response.json()["nombre"] == "Ingeniería de Software"
    assert response.json()["codigo_programa"] == "9999"

def test_obtener_programas(client: TestClient):
    # Obtener la lista de programas
    response = client.get("/programas/")
    assert response.status_code == 200  # Esperamos un status code 200
    assert isinstance(response.json(), list)  # Debe devolver una lista

def test_obtener_programa(client: TestClient):
    # Obtener un programa por ID
    response = client.post("/programas/", json={
        "nombre": "Ingeniería Civil",
        "codigo_programa": "8888"
    })
    program_id = response.json()["id"]
    response = client.get(f"/programas/{program_id}")
    assert response.status_code == 200  # Esperamos un status code 200
    assert response.json()["nombre"] == "Ingeniería Civil"
    assert response.json()["codigo_programa"] == "8888"

def test_actualizar_programa(client: TestClient):
    # Actualizar un programa existente
    response = client.post("/programas/", json={
        "nombre": "Arquitectura",
        "codigo_programa": "7777"
    })
    program_id = response.json()["id"]
    response = client.put(f"/programas/{program_id}", json={
        "nombre": "Arquitectura y Urbanismo",
        "codigo_programa": "7777"
    })
    assert response.status_code == 200  # Esperamos un status code 200
    assert response.json()["nombre"] == "Arquitectura y Urbanismo"

def test_eliminar_programa(client: TestClient):
    # Eliminar un programa
    response = client.post("/programas/", json={
        "nombre": "Diseño Gráfico",
        "codigo_programa": "6666"
    })
    program_id = response.json()["id"]
    response = client.delete(f"/programas/{program_id}")
    assert response.status_code == 200  # Esperamos un status code 200
    response = client.get(f"/programas/{program_id}")
    assert response.status_code == 404  # Esperamos un error 404, ya que el programa fue eliminado
