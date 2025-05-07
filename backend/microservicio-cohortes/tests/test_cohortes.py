import pytest
from uuid import uuid4

@pytest.fixture
def crear_cohorte(client):
    def _crear_cohorte(nombre="Cohorte 2025"):
        datos = {
            "id": 1,
            "nombre": nombre,
            "programa_academico": "Ingeniería de Sistemas",
            "fecha_inicio": "2025-01-15",
            "estado": "Activa"
        }
        response = client.post("/cohortes/crear_cohorte", json=datos)
        assert response.status_code == 201
        return datos
    return _crear_cohorte


def test_crear_cohorte(client):
    nombre_unico = f"Cohorte {uuid4()}"
    datos = {
        "id": 1,
        "nombre": nombre_unico,
        "programa_academico": "Ingeniería de Sistemas",
        "fecha_inicio": "2025-01-15",
        "estado": "Activa"
    }
    response = client.post("/cohortes/crear_cohorte", json=datos)
    assert response.status_code == 201
    assert response.json()["nombre"] == nombre_unico


def test_obtener_cohortes(client, crear_cohorte):
    crear_cohorte()
    response = client.get("/cohortes/")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert any(c["nombre"] == "Cohorte 2025" for c in data)


def test_obtener_cohorte_por_id(client, crear_cohorte):
    crear_cohorte()
    response = client.get("/cohortes/1")
    assert response.status_code == 200
    assert response.json()["nombre"] == "Cohorte 2025"


def test_obtener_cohorte_por_nombre(client, crear_cohorte):
    crear_cohorte()
    response = client.get("/cohortes/consultar_por_nombre/Cohorte 2025")
    assert response.status_code == 200
    assert response.json()["programa_academico"] == "Ingeniería de Sistemas"


def test_actualizar_cohorte(client, crear_cohorte):
    crear_cohorte()
    datos_actualizados = {
        "id": 1,
        "nombre": "Cohorte 2025 - Actualizada",
        "programa_academico": "Ingeniería de Software",
        "fecha_inicio": "2025-02-01",
        "estado": "Inactiva"
    }
    response = client.put("/cohortes/actualizar_cohorte/1", json=datos_actualizados)
    assert response.status_code == 200
    assert response.json()["nombre"] == "Cohorte 2025 - Actualizada"


def test_eliminar_cohorte(client, crear_cohorte):
    crear_cohorte()
    response = client.delete("/cohortes/eliminar_cohorte/1")
    assert response.status_code == 200
    assert response.json()["mensaje"] == "Cohorte eliminada correctamente"


def test_cohorte_no_existente(client):
    response = client.get("/cohortes/999")
    assert response.status_code == 404
