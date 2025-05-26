# 🏫 Sistema de Gestión de Espacios Físicos Académicos  
Forma parte de una arquitectura de microservicios desplegada en **Kubernetes**, con imágenes almacenadas en **DockerHub** y desarrollos locales facilitados por **Telepresence**.
<a href="https://deepwiki.com/Jhon98E/sistema-de-gestion-de-espacios-fisicos-academicos"><img src="https://deepwiki.com/badge.svg" alt="Ask DeepWiki"></a>
---

## 📌 Requisitos Previos

Antes de continuar, asegúrate de tener:

- ✅ [kubectl](https://kubernetes.io/docs/tasks/tools/)
- ✅ Acceso a un clúster de Kubernetes (local o remoto)
- ✅ [Docker](https://www.docker.com/) (para desarrollo local)
- ✅ [Telepresence](https://telepresence.io/docs/install/client) (para debug/desarrollo local)
- ✅ Helm (para instalación de servicios comunes)

---

## 🚀 Instalación y Despliegue

### 1️⃣ Clonar el repositorio
📁 Clona el proyecto en una ruta corta, como:
C:\sistema-de-gestion-de-espacios-fisicos-academicos
Esto evita errores por rutas demasiado largas en Windows.

```bash
git clone https://github.com/Jhon98E/sistema-de-gestion-de-espacios-fisicos-academicos.git
```

2️⃣ Despliegue en Kubernetes
Cada microservicio se construye automáticamente a través de CI/CD y su imagen es publicada en DockerHub. El archivo deployment.yaml de Kubernetes usa esta imagen directamente.

🌐 Paso a paso:
Revisar/editar deployment.yaml:
Asegúrate de que el campo image tenga la imagen correspondiente:
```bash
containers:
  - name: ms-usuarios
    image: docker.io/tuusuario/ms-usuarios:latest
    ports:
      - containerPort: 8000
Aplicar el deployment:
```
Una vez confirmada la conexión al clúster, aplica los manifiestos de Kubernetes para cada microservicio. Asegúrate de estar dentro del directorio correspondiente a cada uno (microservicio-usuarios, microservicio-programas, etc.).
```bash

kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
```
Verificar los pods y servicios:

```bash
kubectl get pods
kubectl get svc
```
---
📝 Instrucciones para correr el frontend Flutter en Windows
🚨 Recomendación importante

Para evitar errores de longitud de ruta en Windows, clona el proyecto en una carpeta directamente en C:\ (por ejemplo: C:\mi_app_frontend).

📦 Requisitos previos

Antes de continuar, asegúrate de tener:

Flutter instalado (https://docs.flutter.dev/get-started/install)

Soporte para Windows Desktop activado:
flutter config --enable-windows-desktop


```bash
cd ruta\al\proyecto\frontend
cd C:\mi_app_frontend

flutter clean
flutter run -d windows
```
✅ Si todo está configurado correctamente, Flutter compilará y abrirá la aplicación como una app de escritorio de Windows.
