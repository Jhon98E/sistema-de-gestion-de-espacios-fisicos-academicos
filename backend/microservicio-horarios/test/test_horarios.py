from fastapi import status

def test_crear_horario(client):
    nuevo = {
        "hora_inicio": "08:00:00",
        "hora_fin": "10:00:00",
        "dia_semana": "Lunes",
        "jornada": "diurno"
    }
    response = client.post("/horarios/crear-horario", json=nuevo)
    assert response.status_code == status.HTTP_201_CREATED
    data = response.json()
    assert data["hora_inicio"] == "08:00:00"
    assert data["hora_fin"] == "10:00:00"
    assert data["dia_semana"] == "Lunes"
    assert data["jornada"] == "diurno"
    assert "id" in data

def test_obtener_todos_los_horarios(client):
    # Insertar horario de prueba
    client.post("/horarios/crear-horario", json={
        "hora_inicio": "09:00:00",
        "hora_fin": "11:00:00",
        "dia_semana": "Martes",
        "jornada": "diurno"
    })
    response = client.get("/horarios/")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1

def test_obtener_horario_por_id(client):
    nuevo = {
        "hora_inicio": "10:00:00",
        "hora_fin": "12:00:00",
        "dia_semana": "Miércoles",
        "jornada": "diurno"
    }
    res = client.post("/horarios/crear-horario", json=nuevo)
    horario_id = res.json()["id"]

    response = client.get(f"/horarios/{horario_id}")
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["dia_semana"] == "Miércoles"

def test_actualizar_horario(client):
    res = client.post("/horarios/crear-horario", json={
        "hora_inicio": "14:00:00",
        "hora_fin": "16:00:00",
        "dia_semana": "Jueves",
        "jornada": "diurno"
    })
    horario_id = res.json()["id"]

    nuevo_dato = {
        "id": horario_id,
        "hora_inicio": "15:00:00",
        "hora_fin": "17:00:00",
        "dia_semana": "Jueves",
        "jornada": "diurno"
    }
    response = client.put(f"/horarios/actualizar-horario/{horario_id}", json=nuevo_dato)
    assert response.status_code == status.HTTP_200_OK
    data = response.json()
    assert data["hora_inicio"] == "15:00:00"

def test_eliminar_horario(client):
    res = client.post("/horarios/crear-horario", json={
        "hora_inicio": "12:00:00",
        "hora_fin": "14:00:00",
        "dia_semana": "Viernes",
        "jornada": "diurno"
    })
    horario_id = res.json()["id"]

    response = client.delete(f"/horarios/eliminar-horario/{horario_id}")
    assert response.status_code == status.HTTP_200_OK

    # Confirmar que fue eliminado
    response = client.get(f"/horarios/{horario_id}")
    assert response.status_code == status.HTTP_404_NOT_FOUND

def test_obtener_asignaturas_programas_cohortes(client):
    response = client.get("/asignaturas_programas_cohortes/")
    assert response.status_code == status.HTTP_200_OK
    assert isinstance(response.json(), list)





