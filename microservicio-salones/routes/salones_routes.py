from fastapi import APIRouter, HTTPException
from models.salones_model import salones, Salon

salon_router = APIRouter()

# Obtener todos los salones
@salon_router.get("/")
async def consultar_salones():
    return salones

# Obtener un salón por ID
@salon_router.get("/{salon_id}")
async def obtener_salon(salon_id: int):
    for salon in salones:
        if salon.id == salon_id:
            return salon
    raise HTTPException(status_code=404, detail="Salón no encontrado")

# Crear un nuevo salón con ID único
@salon_router.post("/")
async def crear_salon(salon: Salon):
    nuevo_id = max([s.id for s in salones], default=0) + 1  # Asignar ID automáticamente
    nuevo_salon = Salon(id=nuevo_id, name=salon.name)
    salones.append(nuevo_salon)
    return nuevo_salon

# Actualizar un salón existente
@salon_router.put("/{salon_id}")
async def actualizar_salon(salon_id: int, salon_actualizado: Salon):
    for i, salon in enumerate(salones):
        if salon.id == salon_id:
            salones[i] = Salon(id=salon_id, name=salon_actualizado.name)  # Asegurar instancia válida
            return salones[i]
    raise HTTPException(status_code=404, detail="Salón no encontrado")

# Eliminar un salón
@salon_router.delete("/{salon_id}")
async def eliminar_salon(salon_id: int):
    for i, salon in enumerate(salones):
        if salon.id == salon_id:
            salones.pop(i)  # pop() en lugar de del para evitar errores de índice
            return {"message": f"Salón {salon_id} eliminado"}
    raise HTTPException(status_code=404, detail="Salón no encontrado")




"""from fastapi import APIRouter
from models.salones_model import salones

salon_router=APIRouter()

@salon_router.get("/")
async def consultar_salones():
    return salones"""

