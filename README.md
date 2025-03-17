# Sistema de Gestión de Espacios Físicos Académicos
## Microservicio de Usuarios

Este microservicio gestiona la autenticación y administración de usuarios. Se ejecuta en un entorno Docker con una base de datos PostgreSQL.

## 📌 Requisitos
Antes de comenzar, asegúrate de tener instalado e iniciar Docker:
- [Docker](https://www.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## 🚀 Instalación y Configuración

### 1️⃣ Clonar el repositorio
```sh
  git clone https://github.com/Jhon98E/sistema-de-gestion-de-espacios-fisicos-academicos.git
  cd microservicio-usuarios #O el microservicio que desee construir 
```

### 2️⃣ Configurar el puerto del microservicio
Cada microservicio debe ejecutarse en un puerto distinto para evitar conflictos. Por ejemplo:
- **Microservicio de Usuarios** → `8000`
- **Microservicio de Programas** → `8001`
- **Microservicio de Reservas** → `8002`

Abre el archivo `docker-compose.yml` y edita la sección del servicio para asegurarte de que el puerto asignado sea único.

Ejemplo de configuración para el microservicio de usuarios:
```yaml
services:
  ms-usuarios:
    build: .
    ports:
      - "8000:8000"
```
Para otro microservicio, cambia el puerto `8000` por `8001`, `8002`, etc.

### 3️⃣ Construir y levantar los contenedores
Ejecuta el siguiente comando para iniciar el microservicio y la base de datos:
```sh
docker-compose up -d --build
```
Esto iniciará:
- 📦 **PostgreSQL** en el puerto `5432`
- ⚙ **Microservicio de usuarios** en el puerto `8000` (o el asignado)

### 4️⃣ Verificar que los contenedores están corriendo
```sh
docker ps
```
Deberías ver algo similar a esto:
```
CONTAINER ID   IMAGE             PORTS                    NAMES
123abc456def   microservicio-usuarios   0.0.0.0:8000->8000/tcp   ms-usuarios
789xyz012ghi   postgres:15-alpine   0.0.0.0:5432->5432/tcp   postgres_db
```

## 🔍 Acceder al Microservicio
- **API:** `http://localhost:8000`
- **Documentación (si usas FastAPI):** `http://localhost:8000/docs`

## 🛠️ Comandos Útiles

### Detener los contenedores
```sh
docker-compose down
```

### Ver logs del microservicio
```sh
docker-compose logs -f ms-usuarios
```

### Ingresar a la base de datos PostgreSQL
```sh
docker exec -it postgres_db psql -U postgres -d usuarios
```

