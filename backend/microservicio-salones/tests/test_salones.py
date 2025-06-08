from fastapi.testclient import TestClient
import pytest

# Token de prueba (puedes usar uno fijo para tests)
TEST_TOKEN = "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxIiwiZXhwIjoxNzQ5MzYxMDkwfQ.6kWWtVK5cdXycr327--qfuNIwppO3BFAp8qvWPLIRZg"

@pytest.fixture
def headers():
    return {"Authorization": TEST_TOKEN}

def test_crear_salon(client, headers):
    nuevo_salon = {
        "nombre": "Salón A",
        "capacidad": 40,
        "disponibilidad": True,
        "tipo": "Aula"
    }

    response = client.post("/salones/", json=nuevo_salon, headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert data["nombre"] == nuevo_salon["nombre"]
    assert data["capacidad"] == nuevo_salon["capacidad"]
    assert data["disponibilidad"] == nuevo_salon["disponibilidad"]
    assert data["tipo"] == nuevo_salon["tipo"]

def test_obtener_salon(client, headers):
    # Crear un salón primero
    response_crear = client.post("/salones/", 
        json={
            "nombre": "Salón B",
            "capacidad": 30,
            "disponibilidad": True,
            "tipo": "Laboratorio"
        },
        headers=headers
    )
    assert response_crear.status_code == 200
    salon_id = response_crear.json()["id"]

    # Obtener el salón
    response = client.get(f"/salones/{salon_id}", headers=headers)
    assert response.status_code == 200
    assert response.json()["nombre"] == "Salón B"

def test_actualizar_salon(client, headers):
    # Crear un salón
    response_crear = client.post("/salones/", 
        json={
            "nombre": "Salón C",
            "capacidad": 25,
            "disponibilidad": True,
            "tipo": "Aula"
        },
        headers=headers
    )
    salon_id = response_crear.json()["id"]

    # Actualizarlo
    response = client.put(
        f"/salones/{salon_id}", 
        json={
            "nombre": "Salón C Actualizado",
            "capacidad": 35,
            "disponibilidad": False,
            "tipo": "Auditorio"
        },
        headers=headers
    )
    assert response.status_code == 200
    data = response.json()
    assert data["nombre"] == "Salón C Actualizado"
    assert data["capacidad"] == 35
    assert not data["disponibilidad"]
    assert data["tipo"] == "Auditorio"

def test_eliminar_salon(client, headers):
    # Crear un salón
    response_crear = client.post("/salones/", 
        json={
            "nombre": "Salón D",
            "capacidad": 20,
            "disponibilidad": True,
            "tipo": "Sala"
        },
        headers=headers
    )
    salon_id = response_crear.json()["id"]

    # Eliminar el salón
    response = client.delete(f"/salones/{salon_id}", headers=headers)
    assert response.status_code == 200
    assert response.json()["message"] == f"Salón {salon_id} eliminado"

    # Verificar que no se puede obtener
    response_get = client.get(f"/salones/{salon_id}")
    assert response_get.status_code == 404