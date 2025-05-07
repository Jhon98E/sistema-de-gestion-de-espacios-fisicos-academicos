def test_crear_asignatura(client):
    nueva = {"id": 1, "nombre": "Matemáticas", "programa": "Ingeniería"}
    response = client.post("/asignatura/crear-asignatura", json=nueva)
    assert response.status_code == 200
    data = response.json()
    assert data["nombre"] == "Matemáticas"
    assert data["programa"] == "Ingeniería"


def test_consultar_todas_las_asignaturas(client):
    asignatura1 = {"id": 2, "nombre": "Física", "programa": "Ciencias"}
    asignatura2 = {"id": 3, "nombre": "Química", "programa": "Ciencias"}
    client.post("/asignatura/crear-asignatura", json=asignatura1)
    client.post("/asignatura/crear-asignatura", json=asignatura2)

    res = client.get("/asignatura/")
    assert res.status_code == 200
    data = res.json()
    assert isinstance(data, list)
    assert any(a["nombre"] == "Física" for a in data)
    assert any(a["nombre"] == "Química" for a in data)


def test_consultar_asignatura_por_id(client):
    nueva = {"id": 4, "nombre": "Historia", "programa": "Humanidades"}
    res = client.post("/asignatura/crear-asignatura", json=nueva)
    assert res.status_code == 200
    asignatura_id = res.json()["id"]

    res_get = client.get(f"/asignatura/{asignatura_id}")
    assert res_get.status_code == 200
    data = res_get.json()
    assert data["nombre"] == "Historia"
    assert data["programa"] == "Humanidades"


def test_actualizar_asignatura(client):
    original = {"id": 5, "nombre": "Biología", "programa": "Ciencias Naturales"}
    nueva = {"id": 5, "nombre": "Biología Actualizada", "programa": "Ciencias Naturales"}
    res = client.post("/asignatura/crear-asignatura", json=original)
    assert res.status_code == 200
    asignatura_id = res.json()["id"]

    res_put = client.put(f"/asignatura/actualizar-asignatura/{asignatura_id}", json=nueva)
    assert res_put.status_code == 200
    data = res_put.json()
    assert data["nombre"] == "Biología Actualizada"


def test_eliminar_asignatura(client):
    nueva = {"id": 6, "nombre": "Arte", "programa": "Artes Visuales"}
    res = client.post("/asignatura/crear-asignatura", json=nueva)
    assert res.status_code == 200
    asignatura_id = res.json()["id"]

    res_delete = client.delete(f"/asignatura/eliminar-asignatura/{asignatura_id}")
    assert res_delete.status_code == 200
    data = res_delete.json()
    assert "ha sido eliminada" in data["message"]

    res_get = client.get(f"/asignatura/{asignatura_id}")
    assert res_get.status_code == 404
