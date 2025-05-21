from datetime import time

def test_crear_horario(client):
    nuevo = {
        "dia_semana": "Lunes",
        "hora_inicio": "08:00:00",
        "hora_fin": "10:00:00",
        "jornada": "diurno"
    }
    response = client.post("/horarios/crear-horario", json=nuevo)
    assert response.status_code == 201
    data = response.json()
    assert data["dia_semana"] == "Lunes"
    assert data["hora_inicio"] == "08:00:00"
    assert data["hora_fin"] == "10:00:00"
    assert data["jornada"] == "diurno"
    assert "id" in data

def test_obtener_todos_los_horarios(client):
    # Insertar horario de prueba
    client.post("/horarios/crear-horario", json={
        "dia_semana": "Martes", 
        "hora_inicio": "09:00:00", 
        "hora_fin": "11:00:00", 
        "jornada": "diurno"
    })
    response = client.get("/horarios/")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1

def test_obtener_horario_por_id(client):
    nuevo = {
        "dia_semana": "Miércoles", 
        "hora_inicio": "10:00:00", 
        "hora_fin": "12:00:00", 
        "jornada": "nocturno"
    }
    res = client.post("/horarios/crear-horario", json=nuevo)
    horario_id = res.json()["id"]

    response = client.get(f"/horarios/{horario_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["dia_semana"] == "Miércoles"
    assert data["jornada"] == "nocturno"

def test_actualizar_horario(client):
    # Crear uno nuevo
    res = client.post("/horarios/crear-horario", json={
        "dia_semana": "Jueves", 
        "hora_inicio": "14:00:00", 
        "hora_fin": "16:00:00", 
        "jornada": "diurno"
    })
    horario_id = res.json()["id"]

    # Actualizar
    nuevo_dato = {
        "dia_semana": "Jueves", 
        "hora_inicio": "15:00:00", 
        "hora_fin": "17:00:00", 
        "jornada": "diurno"
    }
    response = client.put(f"/horarios/actualizar-horario/{horario_id}", json=nuevo_dato)
    assert response.status_code == 200
    data = response.json()
    assert data["hora_inicio"] == "15:00:00"

def test_eliminar_horario(client):
    res = client.post("/horarios/crear-horario", json={
        "dia_semana": "Viernes", 
        "hora_inicio": "12:00:00", 
        "hora_fin": "14:00:00", 
        "jornada": "diurno"
    })
    horario_id = res.json()["id"]

    response = client.delete(f"/horarios/eliminar-horario/{horario_id}")
    assert response.status_code == 200

    # Confirmar que fue eliminado
    response = client.get(f"/horarios/{horario_id}")
    assert response.status_code == 404

def test_validaciones_horario(client):
    # Probar con un día de semana inválido
    nuevo = {
        "dia_semana": "Domingo",  # Día inválido según el enum
        "hora_inicio": "08:00:00",
        "hora_fin": "10:00:00",
        "jornada": "diurno"
    }
    response = client.post("/horarios/crear-horario", json=nuevo)
    assert response.status_code == 422  # Validation error

    # Probar con jornada inválida
    nuevo = {
        "dia_semana": "Lunes",
        "hora_inicio": "08:00:00",
        "hora_fin": "10:00:00",
        "jornada": "vespertino"  # Jornada inválida según el enum
    }
    response = client.post("/horarios/crear-horario", json=nuevo)
    assert response.status_code == 422  # Validation error

    # Probar crear un horario duplicado
    nuevo = {
        "dia_semana": "Lunes",
        "hora_inicio": "08:00:00",
        "hora_fin": "10:00:00",
        "jornada": "diurno"
    }
    client.post("/horarios/crear-horario", json=nuevo)
    response = client.post("/horarios/crear-horario", json=nuevo)
    assert response.status_code == 409  # Conflict