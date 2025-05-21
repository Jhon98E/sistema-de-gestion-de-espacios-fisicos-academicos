import pytest
from unittest.mock import patch, AsyncMock
from datetime import date

# Mock para evitar dependencias externas en las pruebas
@pytest.fixture(autouse=True)
def mock_external_services():
    with patch("controllers.external.asignatura_programa_cohorte_controller.verificar_programa_existe", 
               new_callable=AsyncMock) as mock_programa, \
         patch("controllers.external.asignatura_programa_cohorte_controller.verificar_cohorte_existe", 
               new_callable=AsyncMock) as mock_cohorte, \
         patch("controllers.external.asignatura_programa_cohorte_controller.verificar_salon_existe", 
               new_callable=AsyncMock) as mock_salon:
        
        # Configurar mocks para que devuelvan None (éxito)
        mock_programa.return_value = None
        mock_cohorte.return_value = None
        mock_salon.return_value = None
        
        yield

# Helper para crear entidades necesarias para las pruebas
def crear_asignatura_programa(client, db_session):
    # Primero, creamos un horario para usar en las pruebas
    horario_data = {
        "dia_semana": "Lunes",
        "hora_inicio": "08:00:00",
        "hora_fin": "10:00:00",
        "jornada": "diurno"
    }
    horario_response = client.post("/horarios/crear-horario", json=horario_data)
    horario_id = horario_response.json()["id"]
    
    # Aquí insertamos directamente en la base de datos la entidad AsignaturaPrograma
    # ya que está fuera del alcance de este microservicio pero es necesaria para las pruebas
    from models.external.asignatura_programa import AsignaturaPrograma
    asignatura_programa = AsignaturaPrograma(asignatura_id=1, programa_id=1)
    db_session.add(asignatura_programa)
    db_session.commit()
    db_session.refresh(asignatura_programa)
    
    # También tenemos que insertar un salon directamente
    from models.external.salones_model import SalonDB
    salon = SalonDB(nombre="Salón de prueba", capacidad=30, disponibilidad=True, tipo="Normal")
    db_session.add(salon)
    db_session.commit()
    db_session.refresh(salon)
    
    return {
        "asignatura_programa_id": asignatura_programa.id,
        "horario_id": horario_id,
        "salon_id": salon.id
    }

# TESTS PARA ASIGNATURA PROGRAMA COHORTE

def test_crear_asignatura_programa_cohorte(client, db_session):
    entidades = crear_asignatura_programa(client, db_session)
    
    data = {
        "asignatura_programa_id": entidades["asignatura_programa_id"],
        "salon_id": entidades["salon_id"],
        "horario_id": entidades["horario_id"],
        "fecha_inicio": str(date.today()),
        "fecha_fin": str(date(2025, 12, 31))
    }
    
    response = client.post("/asignaturas_programas_cohortes", json=data)
    assert response.status_code == 200
    
    # Verificar que la respuesta contiene los datos enviados
    response_data = response.json()
    assert response_data["asignatura_programa_id"] == entidades["asignatura_programa_id"]
    assert response_data["horario_id"] == entidades["horario_id"]
    
def test_obtener_asignaturas_programas_cohortes(client, db_session):
    # Crear una entrada para asegurarse que existe al menos una
    entidades = crear_asignatura_programa(client, db_session)
    data = {
        "asignatura_programa_id": entidades["asignatura_programa_id"],
        "salon_id": entidades["salon_id"],
        "horario_id": entidades["horario_id"],
        "fecha_inicio": str(date.today()),
        "fecha_fin": str(date(2025, 12, 31))
    }
    client.post("/asignaturas_programas_cohortes", json=data)
    
    # Obtener todas las entradas
    response = client.get("/asignaturas_programas_cohortes")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1

def test_obtener_asignatura_programa_cohorte_por_id(client, db_session):
    # Crear una entrada
    entidades = crear_asignatura_programa(client, db_session)
    data = {
        "asignatura_programa_id": entidades["asignatura_programa_id"],
        "salon_id": entidades["salon_id"],
        "horario_id": entidades["horario_id"],
        "fecha_inicio": str(date.today()),
        "fecha_fin": str(date(2025, 12, 31))
    }
    client.post("/asignaturas_programas_cohortes", json=data)
    
    # AQUÍ APLICAMOS LA SOLUCIÓN: Obtener todos y buscar el correcto
    all_items = client.get("/asignaturas_programas_cohortes").json()
    item = next(
        (item for item in all_items 
         if item["asignatura_programa_id"] == entidades["asignatura_programa_id"] 
         and item["horario_id"] == entidades["horario_id"]), 
        None
    )
    assert item is not None, "No se encontró el item creado"
    item_id = item["id"]
    
    # Obtener por ID
    response = client.get(f"/asignaturas_programas_cohortes/{item_id}")
    assert response.status_code == 200
    data = response.json()
    assert data["id"] == item_id

def test_eliminar_asignatura_programa_cohorte(client, db_session):
    # Crear una entrada
    entidades = crear_asignatura_programa(client, db_session)
    data = {
        "asignatura_programa_id": entidades["asignatura_programa_id"],
        "salon_id": entidades["salon_id"],
        "horario_id": entidades["horario_id"],
        "fecha_inicio": str(date.today()),
        "fecha_fin": str(date(2025, 12, 31))
    }
    client.post("/asignaturas_programas_cohortes", json=data)
    
    # AQUÍ APLICAMOS LA SOLUCIÓN: Obtener todos y buscar el correcto
    all_items = client.get("/asignaturas_programas_cohortes").json()
    item = next(
        (item for item in all_items 
         if item["asignatura_programa_id"] == entidades["asignatura_programa_id"] 
         and item["horario_id"] == entidades["horario_id"]), 
        None
    )
    assert item is not None, "No se encontró el item creado"
    item_id = item["id"]
    
    # Eliminar
    response = client.delete(f"/asignaturas_programas_cohortes/{item_id}")
    assert response.status_code == 200
    
    # Verificar que fue eliminado
    response = client.get(f"/asignaturas_programas_cohortes/{item_id}")
    assert response.status_code == 200  # No devuelve 404 porque tu API devuelve None en vez de error
    assert response.json() is None

# TESTS PARA ASIGNATURA PROGRAMA COHORTE DETALLE

def test_crear_asignatura_programa_cohorte_detalle(client, db_session):
    # Crear una AsignaturaProgramaCohorte
    entidades = crear_asignatura_programa(client, db_session)
    data = {
        "asignatura_programa_id": entidades["asignatura_programa_id"],
        "salon_id": entidades["salon_id"],
        "horario_id": entidades["horario_id"],
        "fecha_inicio": str(date.today()),
        "fecha_fin": str(date(2025, 12, 31))
    }
    client.post("/asignaturas_programas_cohortes", json=data)
    
    # BUSCAR EL ID DE LA ASIGNATURA PROGRAMA COHORTE CREADA
    all_apc = client.get("/asignaturas_programas_cohortes").json()
    apc_item = next(
        (item for item in all_apc 
         if item["asignatura_programa_id"] == entidades["asignatura_programa_id"] 
         and item["horario_id"] == entidades["horario_id"]), 
        None
    )
    assert apc_item is not None, "No se encontró la AsignaturaProgramaCohorte creada"
    apc_id = apc_item["id"]
    
    # Crear una cohorte directamente en la base de datos
    from models.external.cohortes_model import CohorteDB
    cohorte = CohorteDB(
        nombre="Cohorte de prueba", 
        programa_id=1, 
        fecha_inicio=date.today(), 
        fecha_fin=date(2025, 12, 31),
        estado="Activo"
    )
    db_session.add(cohorte)
    db_session.commit()
    db_session.refresh(cohorte)
    
    # Ahora crear el detalle
    response = client.post(
        f"/asignaturas_programas_cohortes_detalles?asignatura_programa_cohorte_id={apc_id}&cohorte_id={cohorte.id}"
    )
    assert response.status_code == 200
    response_data = response.json()
    assert "message" in response_data
    assert "data" in response_data

def test_obtener_asignaturas_programas_cohortes_detalles(client, db_session):
    # Preparar datos y crear un detalle primero
    entidades = crear_asignatura_programa(client, db_session)
    data = {
        "asignatura_programa_id": entidades["asignatura_programa_id"],
        "salon_id": entidades["salon_id"],
        "horario_id": entidades["horario_id"],
        "fecha_inicio": str(date.today()),
        "fecha_fin": str(date(2025, 12, 31))
    }
    client.post("/asignaturas_programas_cohortes", json=data)
    
    # BUSCAR EL ID DE LA ASIGNATURA PROGRAMA COHORTE CREADA
    all_apc = client.get("/asignaturas_programas_cohortes").json()
    apc_item = next(
        (item for item in all_apc 
         if item["asignatura_programa_id"] == entidades["asignatura_programa_id"] 
         and item["horario_id"] == entidades["horario_id"]), 
        None
    )
    assert apc_item is not None, "No se encontró la AsignaturaProgramaCohorte creada"
    apc_id = apc_item["id"]
    
    # Crear cohorte
    from models.external.cohortes_model import CohorteDB
    cohorte = CohorteDB(
        nombre="Cohorte de prueba", 
        programa_id=1, 
        fecha_inicio=date.today(), 
        fecha_fin=date(2025, 12, 31),
        estado="Activo"
    )
    db_session.add(cohorte)
    db_session.commit()
    db_session.refresh(cohorte)
    
    # Crear detalle
    client.post(
        f"/asignaturas_programas_cohortes_detalles?asignatura_programa_cohorte_id={apc_id}&cohorte_id={cohorte.id}"
    )
    
    # Obtener todos los detalles
    response = client.get("/asignaturas_programas_cohortes_detalles")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert len(data) >= 1

# def test_eliminar_asignatura_programa_cohorte_detalle(client, db_session):
#     # Preparar datos y crear un detalle primero
#     entidades = crear_asignatura_programa(client, db_session)
#     data = {
#         "asignatura_programa_id": entidades["asignatura_programa_id"],
#         "salon_id": entidades["salon_id"], 
#         "horario_id": entidades["horario_id"],
#         "fecha_inicio": str(date.today()),
#         "fecha_fin": str(date(2025, 12, 31))
#     }
#     client.post("/asignaturas_programas_cohortes", json=data)
    
#     # BUSCAR EL ID DE LA ASIGNATURA PROGRAMA COHORTE CREADA
#     all_apc = client.get("/asignaturas_programas_cohortes").json()
#     apc_item = next(
#         (item for item in all_apc 
#          if item["asignatura_programa_id"] == entidades["asignatura_programa_id"] 
#          and item["horario_id"] == entidades["horario_id"]), 
#         None
#     )
#     assert apc_item is not None, "No se encontró la AsignaturaProgramaCohorte creada"
#     apc_id = apc_item["id"]
    
#     # Crear cohorte
#     from models.external.cohortes_model import CohorteDB
#     cohorte = CohorteDB(
#         nombre="Cohorte de prueba", 
#         programa_id=1, 
#         fecha_inicio=date.today(), 
#         fecha_fin=date(2025, 12, 31),
#         estado="Activo"
#     )
#     db_session.add(cohorte)
#     db_session.commit()
#     db_session.refresh(cohorte)
    
#     # Crear detalle
#     response = client.post(
#         f"/asignaturas_programas_cohortes_detalles?asignatura_programa_cohorte_id={apc_id}&cohorte_id={cohorte.id}"
#     )
#     detalle_id = response.json()["data"]
    
#     # Eliminar detalle
#     response = client.delete(f"/asignaturas_programas_cohortes_detalles/{detalle_id}")
#     assert response.status_code == 200
    
#     # Verificar eliminación - depende de cómo maneje tu API este caso
#     # Si devuelve 404, cambiar la aseveración
#     response = client.get(f"/asignaturas_programas_cohortes_detalles/{detalle_id}")
#     assert response.status_code == 200