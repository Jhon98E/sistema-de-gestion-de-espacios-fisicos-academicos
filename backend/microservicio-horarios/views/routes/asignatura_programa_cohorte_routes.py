from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from controllers.external.asignatura_programa_cohorte_controller import obtener_asignaturas_programas_cohortes, obtener_asignatura_programa_cohorte_por_id, crear_asignatura_programa_cohorte, eliminar_asignatura_programa_cohorte, obtener_asignaturas_programas_cohortes_detalle, crear_asignatura_programa_cohorte_detalle, eliminar_asignatura_programa_cohorte_detalle, actualizar_asignatura_programa_cohorte
from controllers.repositories.database import get_db
from controllers.services.auth.auth_service import obtener_usuario_actual
from models.external.asignatura_programa_cohorte import AsignaturaProgramaCohorteBase, AsignaturaProgramaCohorte # noqa: F401
from models.external.asignatura_programa_cohorte_detalle import AsignaturaProgramaCohorteDetalle # noqa: F401


router = APIRouter(tags=["AsignaturaProgramaCohorte"])

# Rutas para AsignaturaProgramaCohorte
@router.get("/asignaturas_programas_cohortes")
def get_asignaturas_programas_cohortes(db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return obtener_asignaturas_programas_cohortes(db)

@router.get("/asignaturas_programas_cohortes/{id}")
def get_asignatura_programa_cohorte(id: int, db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return obtener_asignatura_programa_cohorte_por_id(id, db)

@router.post("/asignaturas_programas_cohortes", response_model=AsignaturaProgramaCohorteBase)
async def create_asignatura_programa_cohorte(
    asignatura_programa_cohorte_data: AsignaturaProgramaCohorteBase,
    db: Session = Depends(get_db),
    usuario_actual: dict = Depends(obtener_usuario_actual)
):
    return await crear_asignatura_programa_cohorte(asignatura_programa_cohorte_data, db)

@router.delete("/asignaturas_programas_cohortes/{id}")
def delete_asignatura_programa_cohorte(id: int, db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return eliminar_asignatura_programa_cohorte(id, db)

# Rutas para AsignaturaProgramaCohorteDetalle
@router.get("/asignaturas_programas_cohortes_detalles")
def get_asignaturas_programas_cohortes_detalle(db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return obtener_asignaturas_programas_cohortes_detalle(db)

@router.post("/asignaturas_programas_cohortes_detalles")
async def create_asignatura_programa_cohorte_detalle(
    asignatura_programa_cohorte_id: int,
    cohorte_id: int,
    db: Session = Depends(get_db),
    usuario_actual: dict = Depends(obtener_usuario_actual)
):
    return await crear_asignatura_programa_cohorte_detalle(asignatura_programa_cohorte_id, cohorte_id, db)


@router.get("/asignaturas_programas_cohortes_detalles/{id}")
def get_asignatura_programa_cohorte_detalle(id: int, db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return obtener_asignaturas_programas_cohortes_detalle(id, db)


@router.delete("/asignaturas_programas_cohortes_detalles/{id}")
def delete_asignatura_programa_cohorte_detalle(id: int, db: Session = Depends(get_db), usuario_actual: dict = Depends(obtener_usuario_actual)):
    return eliminar_asignatura_programa_cohorte_detalle(id, db)


@router.put("/asignaturas_programas_cohortes/{id}", response_model=AsignaturaProgramaCohorteBase)
async def update_asignatura_programa_cohorte_route(
    id: int,
    asignatura_programa_cohorte_update_data: AsignaturaProgramaCohorteBase,
    db: Session = Depends(get_db),
    usuario_actual: dict = Depends(obtener_usuario_actual)
):
    return await actualizar_asignatura_programa_cohorte(id, asignatura_programa_cohorte_update_data, db)