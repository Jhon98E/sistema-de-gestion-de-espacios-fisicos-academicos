import pytest
from unittest.mock import patch, AsyncMock
from datetime import date
from models.cohortes_model import CohorteDB


# Mock para simular la verificación de programas
@pytest.fixture
def mock_verificar_programa():
    with patch("controllers.cohortes_controller.verificar_programa_existe", new_callable=AsyncMock) as mock:
        mock.return_value = None  # Simulamos que el programa existe
        yield mock


@pytest.fixture
def programa_de_prueba(db_session):
    from models.external.programa_model import Programa
    nuevo_programa = Programa(
        id=1,  # Aseguramos un ID fijo para pruebas
        nombre="Ingeniería de Sistemas",
        descripcion="Carrera profesional",
        codigo_programa="IS01"
    )
    db_session.add(nuevo_programa)
    db_session.commit()
    db_session.refresh(nuevo_programa)
    return nuevo_programa


@pytest.fixture
def cohorte_prueba(db_session, programa_de_prueba, mock_verificar_programa):
    # Crear directamente en la base de datos para evitar llamadas HTTP
    nueva_cohorte = CohorteDB(
        id=1,
        nombre="Cohorte 2025",
        programa_id=programa_de_prueba.id,
        fecha_inicio=date(2025, 1, 15),
        fecha_fin=date(2025, 12, 15),
        estado="Activa"
    )
    db_session.add(nueva_cohorte)
    db_session.commit()
    db_session.refresh(nueva_cohorte)
    return nueva_cohorte


def test_crear_cohorte(client, programa_de_prueba, mock_verificar_programa):
    datos = {
        "id": 2,
        "nombre": "Cohorte Nueva 2025",
        "programa_id": programa_de_prueba.id,
        "fecha_inicio": "2025-01-15",
        "fecha_fin": "2025-12-15",
        "estado": "Activa"
    }
    response = client.post("/cohortes/crear_cohorte", json=datos)
    assert response.status_code == 201
    assert response.json()["nombre"] == "Cohorte Nueva 2025"
    assert mock_verificar_programa.called


def test_obtener_cohortes(client, cohorte_prueba):
    response = client.get("/cohortes/")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1
    assert any(c["nombre"] == "Cohorte 2025" for c in data)


def test_obtener_cohorte_por_id(client, cohorte_prueba):
    response = client.get(f"/cohortes/{cohorte_prueba.id}")
    assert response.status_code == 200
    data = response.json()
    assert data["nombre"] == "Cohorte 2025"
    assert data["programa_id"] == cohorte_prueba.programa_id


def test_obtener_cohorte_por_nombre(client, cohorte_prueba):
    # Corrige según lo que realmente devuelve tu endpoint
    response = client.get(f"/cohortes/consultar_por_nombre/{cohorte_prueba.nombre}")
    assert response.status_code == 200
    data = response.json()
    assert data["nombre"] == "Cohorte 2025"
    # Si tu endpoint incluye información sobre el programa, ajusta esta verificación:
    # assert data["programa"]["nombre"] == "Ingeniería de Sistemas"


def test_actualizar_cohorte(client, cohorte_prueba, mock_verificar_programa):
    datos_actualizados = {
        "id": cohorte_prueba.id,
        "nombre": "Cohorte 2025 - Actualizada",
        "programa_id": cohorte_prueba.programa_id,
        "fecha_inicio": "2025-02-01",
        "fecha_fin": "2025-12-15",
        "estado": "Inactiva"
    }
    response = client.put(f"/cohortes/actualizar_cohorte/{cohorte_prueba.id}", json=datos_actualizados)
    assert response.status_code == 200
    data = response.json()
    assert data["nombre"] == "Cohorte 2025 - Actualizada"
    assert data["estado"] == "Inactiva"
    assert mock_verificar_programa.called


def test_eliminar_cohorte(client, cohorte_prueba):
    response = client.delete(f"/cohortes/eliminar_cohorte/{cohorte_prueba.id}")
    assert response.status_code == 200
    assert response.json()["mensaje"] == "Cohorte eliminada correctamente"
    
    # Verificar que realmente se eliminó
    response_verificacion = client.get(f"/cohortes/{cohorte_prueba.id}")
    assert response_verificacion.status_code == 404


def test_cohorte_no_existente(client):
    response = client.get("/cohortes/999")
    assert response.status_code == 404
    assert "no fue encontrada" in response.json()["detail"]