from models.salones_model import SalonDB

def test_crear_salon(client):
    nuevo_salon = {
        "nombre": "Salón A",
        "capacidad": 40,
        "disponibilidad": True,
        "tipo": "Aula"
    }

    response = client.post("/salones/", json=nuevo_salon)
    assert response.status_code == 200
    data = response.json()
    assert data["nombre"] == nuevo_salon["nombre"]
    assert data["capacidad"] == nuevo_salon["capacidad"]
    assert data["disponibilidad"] == nuevo_salon["disponibilidad"]
    assert data["tipo"] == nuevo_salon["tipo"]

def test_obtener_salon(client):
    # Crear un salón primero
    response_crear = client.post("/salones/", json={
        "nombre": "Salón B",
        "capacidad": 30,
        "disponibilidad": True,
        "tipo": "Laboratorio"
    })
    assert response_crear.status_code == 200
    salon_id = response_crear.json()["id"]

    # Obtener el salón
    response = client.get(f"/salones/{salon_id}")
    assert response.status_code == 200
    assert response.json()["nombre"] == "Salón B"

def test_actualizar_salon(client):
    # Crear un salón
    response_crear = client.post("/salones/", json={
        "nombre": "Salón C",
        "capacidad": 25,
        "disponibilidad": True,
        "tipo": "Aula"
    })
    salon_id = response_crear.json()["id"]

    # Actualizarlo
    response = client.put(f"/salones/{salon_id}", json={
        "nombre": "Salón C Actualizado",
        "capacidad": 35,
        "disponibilidad": False,
        "tipo": "Auditorio"
    })
    assert response.status_code == 200
    data = response.json()
    assert data["nombre"] == "Salón C Actualizado"
    assert data["capacidad"] == 35
    assert data["disponibilidad"] == False
    assert data["tipo"] == "Auditorio"

def test_eliminar_salon(client):
    # Crear un salón
    response_crear = client.post("/salones/", json={
        "nombre": "Salón D",
        "capacidad": 20,
        "disponibilidad": True,
        "tipo": "Sala"
    })
    salon_id = response_crear.json()["id"]

    # Eliminar el salón
    response = client.delete(f"/salones/{salon_id}")
    assert response.status_code == 200
    assert response.json()["message"] == f"Salón {salon_id} eliminado"

    # Verificar que no se puede obtener
    response_get = client.get(f"/salones/{salon_id}")
    assert response_get.status_code == 404
