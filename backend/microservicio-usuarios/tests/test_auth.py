from fastapi.testclient import TestClient

def test_logout(client: TestClient):
    """Test del endpoint de logout"""
    usuario_logout = {
        "nombre": "Logout",
        "apellido": "Test",
        "codigo_usuario": "LOGOUT001",
        "rol": "admin",
        "email": "logout.test@example.com",
        "password": "logout123"
    }
    
    # Crear usuario
    response = client.post("/usuarios/crear-usuario", json=usuario_logout)
    assert response.status_code in [201, 409]
    
    # Login
    login_data = {"username": "LOGOUT001", "password": "logout123"}
    response = client.post("/auth/login", data=login_data)
    assert response.status_code == 200
    
    token = response.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    
    # Probar logout
    response = client.post("/auth/logout", headers=headers)
    assert response.status_code == 200
    response_data = response.json()
    assert "message" in response_data
    assert response_data["usuario"] == "LOGOUT001"

def test_validate_token_valid(client: TestClient):
    """Test de validación de token válido"""
    usuario_validate = {
        "nombre": "Validate",
        "apellido": "Test",
        "codigo_usuario": "VALIDATE001",
        "rol": "admin",
        "email": "validate.test@example.com",
        "password": "validate123"
    }
    
    # Crear usuario
    response = client.post("/usuarios/crear-usuario", json=usuario_validate)
    assert response.status_code in [201, 409]
    
    # Login
    login_data = {"username": "VALIDATE001", "password": "validate123"}
    response = client.post("/auth/login", data=login_data)
    assert response.status_code == 200
    
    token = response.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    
    # Validar token
    response = client.post("/auth/validate-token", headers=headers)
    assert response.status_code == 200
    data = response.json()
    assert data["valid"] == True
    assert "user_id" in data
    assert "codigo_usuario" in data
    assert data["codigo_usuario"] == "VALIDATE001"
    assert "rol" in data

def test_validate_token_invalid(client: TestClient):
    """Test de validación de token inválido"""
    headers = {"Authorization": "Bearer token_completamente_invalido"}
    response = client.post("/auth/validate-token", headers=headers)
    assert response.status_code == 401

# Tests originales corregidos
usuario_test = {
    "nombre": "Carlos",
    "apellido": "López",
    "codigo_usuario": "CL456",
    "rol": "admin",
    "email": "carlos.lopez@example.com",
    "password": "password456"
}

def test_registro_usuario(client: TestClient):
    # Usar datos únicos para este test
    usuario_registro = {
        "nombre": "Registro",
        "apellido": "Test",
        "codigo_usuario": "REG001",
        "rol": "admin",
        "email": "registro.test@example.com",
        "password": "registro123"
    }
    
    response = client.post("/usuarios/crear-usuario", json=usuario_registro)
    assert response.status_code in [201, 409]

def test_login_usuario(client: TestClient):
    # Usar datos únicos para este test
    usuario_login = {
        "nombre": "Login",
        "apellido": "Test",
        "codigo_usuario": "LOGIN001",
        "rol": "admin",
        "email": "login.test@example.com",
        "password": "login123"
    }
    
    # Primero crear el usuario
    response = client.post("/usuarios/crear-usuario", json=usuario_login)
    assert response.status_code in [201, 409]
    
    # Luego hacer login
    login_data = {"username": "LOGIN001", "password": "login123"}
    response = client.post("/auth/login", data=login_data)
    assert response.status_code == 200, f"⚠️ Error en login: {response.json()}"
    assert "access_token" in response.json()

def test_login_fallido(client: TestClient):
    # Intentar login con credenciales que no existen
    login_data = {"username": "NOEXISTE", "password": "wrongpassword"}
    response = client.post("/auth/login", data=login_data)
    assert response.status_code == 400

def test_acceso_ruta_protegida_con_token(client: TestClient):
    # Usar datos únicos para este test
    usuario_protegido = {
        "nombre": "Protected",
        "apellido": "Test",
        "codigo_usuario": "PROT001",
        "rol": "admin",
        "email": "protected.test@example.com",
        "password": "protected123"
    }
    
    # Crear usuario
    response = client.post("/usuarios/crear-usuario", json=usuario_protegido)
    assert response.status_code in [201, 409]
    
    # Login
    login_data = {"username": "PROT001", "password": "protected123"}
    response = client.post("/auth/login", data=login_data)
    assert response.status_code == 200, f"⚠️ Error en login: {response.json()}"
    
    # Obtener token y probar ruta protegida
    token = response.json()["access_token"]
    headers = {"Authorization": f"Bearer {token}"}
    
    # Probar acceso a una ruta protegida (consultar usuarios)
    response = client.get("/usuarios/", headers=headers)
    assert response.status_code == 200