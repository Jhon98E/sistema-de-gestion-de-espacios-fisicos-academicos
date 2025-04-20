def test_crear_horario(client):
    nuevo = {
        "hora_inicio": "08:00",
        "hora_fin": "10:00",
        "dia": "Lunes"
    }
    response = client.post("/horarios/crear-usuario", json=nuevo)
    assert response.status_code == 201
    data = response.json()
    assert data["hora_inicio"] == "08:00"
    assert data["hora_fin"] == "10:00"
    assert data["dia"] == "Lunes"
    assert "id" in data

def test_obtener_todos_los_horarios(client):
    # Insertar horario de prueba
    client.post("/horarios/crear-usuario", json={"hora_inicio": "09:00", "hora_fin": "11:00", "dia": "Martes"})
    response = client.get("/horarios/")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1

def test_obtener_horario_por_id(client):
    nuevo = {"hora_inicio": "10:00", "hora_fin": "12:00", "dia": "Miércoles"}
    res = client.post("/horarios/crear-usuario", json=nuevo)
    horario_id = res.json()["id"]

    response = client.get(f"/horarios/{horario_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["dia"] == "Miércoles"

def test_actualizar_horario(client):
    # Crear uno nuevo
    res = client.post("/horarios/crear-usuario", json={"hora_inicio": "14:00", "hora_fin": "16:00", "dia": "Jueves"})
    horario_id = res.json()["id"]

    # Actualizar
    nuevo_dato = {"id": horario_id, "hora_inicio": "15:00", "hora_fin": "17:00", "dia": "Jueves"}
    response = client.put(f"/horarios/actualizar-usuario/{horario_id}", json=nuevo_dato)
    assert response.status_code == 200
    data = response.json()
    assert data["hora_inicio"] == "15:00"

def test_eliminar_horario(client):
    res = client.post("/horarios/crear-usuario", json={"hora_inicio": "12:00", "hora_fin": "14:00", "dia": "Viernes"})
    horario_id = res.json()["id"]

    response = client.delete(f"/horarios/eliminar-usuario/{horario_id}")
    assert response.status_code == 200

    # Confirmar que fue eliminado
    response = client.get(f"/horarios/{horario_id}")
    assert response.status_code == 404
