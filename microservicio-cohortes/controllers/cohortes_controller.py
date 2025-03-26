from models.cohortes_model import Cohorte, cohortes

def obtenerCohortes():
    return cohortes

def obtenerCohortePorId(id: int):
    for cohorte in cohortes:
        if cohorte.id == id:
            return cohorte
    return {"mensaje": "Cohorte no encontrado"}

def obtenerCohortePorNombre(nombre: str):
    for cohorte in cohortes:
        if cohorte.nombre == nombre:
            return cohorte
    return {"mensaje": "Cohorte no encontrado"}

def crearCohorte(cohorte: Cohorte):
    cohortes.append(cohorte)
    return {"mensaje": "Cohorte creado exitosamente"}

def actualizarCohorte(id: int, cohorte_actualizada):
    for cohorte in cohortes:
        if cohorte.id == id:
            cohorte.nombre = cohorte_actualizada.nombre
            cohorte.programa_academico = cohorte_actualizada.programa_academico
            cohorte.fecha_inicio = cohorte_actualizada.fecha_inicio
            cohorte.estado = cohorte_actualizada.estado
            return {"mensaje": "Cohorte actualizado exitosamente"}
    return {"mensaje": "Cohorte no encontrado"}

def eliminarCohorte(id: int):
    for cohorte in range(len(cohortes)):
        if cohortes[cohorte].id == id:
            del cohortes[cohorte]
            return {"mensaje": "Cohorte eliminado exitosamente"}
    return {"mensaje": "Cohorte no encontrado"}