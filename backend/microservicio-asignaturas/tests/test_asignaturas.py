from fastapi.testclient import TestClient
from main import app

def test_crear_asignatura(client):
    nueva = {"id":1, "nombre": "Matemáticas", "codigo_asignatura": "MAT1001"}
    response = client.post("/asignaturas/crear-asignatura", json=nueva)
    assert response.status_code == 200
    data = response.json()
    assert data["nombre"] == "Matemáticas"
    assert data["codigo_asignatura"] == "MAT1001"


def test_consultar_todas_las_asignaturas(client):
    asignatura1 = {"id":2, "nombre": "Física", "codigo_asignatura": "FIS1001"}
    asignatura2 = {"id":3, "nombre": "Química", "codigo_asignatura": "QUI1001"}
    client.post("/asignaturas/crear-asignatura", json=asignatura1)
    client.post("/asignaturas/crear-asignatura", json=asignatura2)

    res = client.get("/asignaturas/")
    assert res.status_code == 200
    data = res.json()
    assert isinstance(data, list)
    assert any(a["nombre"] == "Física" for a in data)
    assert any(a["nombre"] == "Química" for a in data)


def test_consultar_asignatura_por_id(client):
    nueva = {"id": 4, "nombre": "Historia", "codigo_asignatura": "HUM1001"}
    res = client.post("/asignaturas/crear-asignatura", json=nueva)
    assert res.status_code == 200
    asignatura_id = res.json()["id"]

    res_get = client.get(f"/asignaturas/{asignatura_id}")
    assert res_get.status_code == 200
    data = res_get.json()
    assert data["nombre"] == "Historia"
    assert data["codigo_asignatura"] == "HUM1001"


def test_actualizar_asignatura(client):
    original = {"id": 5, "nombre": "Biología", "codigo_asignatura": "BIO1001"}
    nueva = {"id": 5, "nombre": "Biología Actualizada", "codigo_asignatura": "BIO1001"}
    res = client.post("/asignaturas/crear-asignatura", json=original)
    assert res.status_code == 200
    asignatura_id = res.json()["id"]

    res_put = client.put(f"/asignaturas/actualizar-asignatura/{asignatura_id}", json=nueva)
    assert res_put.status_code == 200
    data = res_put.json()
    assert data["nombre"] == "Biología Actualizada"


def test_eliminar_asignatura(client):
    nueva = {"id": 6, "nombre": "Arte", "codigo_asignatura": "ART1001"}
    res = client.post("/asignaturas/crear-asignatura", json=nueva)
    assert res.status_code == 200
    asignatura_id = res.json()["id"]

    res_delete = client.delete(f"/asignaturas/eliminar-asignatura/{asignatura_id}")
    assert res_delete.status_code == 200
    data = res_delete.json()
    assert "ha sido eliminada" in data["message"]

    res_get = client.get(f"/asignaturas/{asignatura_id}")
    assert res_get.status_code == 404


def test_acceso_no_autorizado(client):
    # Temporalmente quitamos el mock de autenticación
    app.dependency_overrides.clear()
    
    response = client.get("/asignaturas/")
    assert response.status_code == 401
    assert response.json()["detail"] == "Not authenticated"
