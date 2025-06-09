from sqlalchemy.orm import Session
from models.external.asignatura_programa_cohorte import AsignaturaProgramaCohorteBase, AsignaturaProgramaCohorte
from models.external.asignatura_programa_cohorte_detalle import AsignaturaProgramaCohorteDetalle
from models.external.programa_model import Programa
from models.external.cohortes_model import CohorteDB
from models.external.asignatura_programa import AsignaturaPrograma
from models.external.salones_model import SalonDB
from models.horario_model import HorarioDB
from fastapi import HTTPException, status
from sqlalchemy import and_

# URL de otros microservicios (ajustar según los servicios disponibles)
PROGRAMAS_URL = "http://ms-programas:8001/programas"
COHORTES_URL = "http://ms-cohortes:8003/cohortes"
SALONES_URL = "http://ms-salones:8004/salones"
# CRUD para AsignaturaProgramaCohorte
def obtener_asignaturas_programas_cohortes(db: Session):
    return db.query(AsignaturaProgramaCohorte).all()

def obtener_asignatura_programa_cohorte_por_id(id: int, db: Session):
    return db.query(AsignaturaProgramaCohorte).filter(AsignaturaProgramaCohorte.id == id).first()


# ✅ Puedes replicar para programa_id, cohorte_id si lo necesitas
def verificar_programa_existe(programa_id: int, db: Session):
    programa = db.query(Programa).filter(Programa.id == programa_id).first()
    if not programa:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"El programa con ID {programa_id} no existe en la base de datos."
        )

def verificar_cohorte_existe(cohorte_id: int, db: Session):
    cohorte = db.query(CohorteDB).filter(CohorteDB.id == cohorte_id).first()
    if not cohorte:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"El cohorte con ID {cohorte_id} no existe en la base de datos."
        )
            
def verificar_salon_existe(salon_id: int, db: Session):
    salon = db.query(SalonDB).filter(SalonDB.id == salon_id).first()
    if not salon:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"El salón con ID {salon_id} no existe en la base de datos."
        )

# ✅ NUEVO: controlador que valida antes de guardar
async def crear_asignatura_programa_cohorte(asignatura_programa_cohorte_data: AsignaturaProgramaCohorteBase, db: Session):
    asignatura_programa_cohorte = AsignaturaProgramaCohorte(
        asignatura_programa_id=asignatura_programa_cohorte_data.asignatura_programa_id,
        salon_id=asignatura_programa_cohorte_data.salon_id,
        horario_id=asignatura_programa_cohorte_data.horario_id,
        fecha_inicio=asignatura_programa_cohorte_data.fecha_inicio,
        fecha_fin=asignatura_programa_cohorte_data.fecha_fin
    )

    db.add(asignatura_programa_cohorte)
    db.commit()
    db.refresh(asignatura_programa_cohorte)

    return AsignaturaProgramaCohorteBase.model_validate(asignatura_programa_cohorte)


def eliminar_asignatura_programa_cohorte(id: int, db: Session):
    asignatura_programa = db.query(AsignaturaProgramaCohorte).filter(AsignaturaProgramaCohorte.id == id).first()
    if asignatura_programa:
        db.delete(asignatura_programa)
        db.commit()
        return {"message": f"Asig. Programa Cohorte con ID {id} eliminado correctamente"}
    return {"message": f"Asig. Programa Cohorte con ID {id} no encontrado"}

# CRUD para AsignaturaProgramaCohorteDetalle
def obtener_asignaturas_programas_cohortes_detalle(db: Session):
    return db.query(AsignaturaProgramaCohorteDetalle).all()


def obtener_asignatura_programa_cohorte_detalle_por_id(id: int, db: Session):
    return db.query(AsignaturaProgramaCohorteDetalle).filter(AsignaturaProgramaCohorteDetalle.id == id).first()


def crear_asignatura_programa_cohorte_detalle(asignatura_programa_cohorte_id: int, cohorte_id: int, db: Session):
    asignatura_programa_cohorte = db.query(AsignaturaProgramaCohorte).filter(
        AsignaturaProgramaCohorte.id == asignatura_programa_cohorte_id
    ).first()

    if not asignatura_programa_cohorte:
        raise HTTPException(status_code=404, detail="Asignatura-Programa-Cohorte no encontrada")

    # Validar existencia del cohorte (sin await, y pasando `db`)
    verificar_cohorte_existe(cohorte_id, db)

    # Verificar si ya existe un detalle con esa combinación
    existente = db.query(AsignaturaProgramaCohorteDetalle).filter(
        and_(
            AsignaturaProgramaCohorteDetalle.asignatura_programa_cohorte_id == asignatura_programa_cohorte_id,
            AsignaturaProgramaCohorteDetalle.cohorte_id == cohorte_id
        )
    ).first()

    if existente:
        raise HTTPException(
            status_code=400,
            detail=f"La cohorte con ID {cohorte_id} ya está asociada a esa asignatura-programa-cohorte"
        )

    detalle = AsignaturaProgramaCohorteDetalle(
        asignatura_programa_cohorte_id=asignatura_programa_cohorte_id,
        cohorte_id=cohorte_id
    )
    db.add(detalle)
    db.commit()
    db.refresh(detalle)

    return {
        "message": "Detalle creado correctamente",
        "data": detalle.id
    }


def eliminar_asignatura_programa_cohorte_detalle(id: int, db: Session):
    asignatura_programa_cohorte_detalle = db.query(AsignaturaProgramaCohorteDetalle).filter(AsignaturaProgramaCohorteDetalle.id == id).first()
    if asignatura_programa_cohorte_detalle:
        db.delete(asignatura_programa_cohorte_detalle)
        db.commit()
        return {"message": f"Detalle con ID {id} eliminado correctamente"}
    return {"message": f"Detalle con ID {id} no encontrado"}

# ✅ NUEVO: Método para actualizar AsignaturaProgramaCohorte
async def actualizar_asignatura_programa_cohorte(
    id: int,
    asignatura_programa_cohorte_data: AsignaturaProgramaCohorteBase, # <- Usar tu schema Pydantic aquí
    db: Session
):
    # 1. Obtener el registro existente
    asignatura_programa_cohorte = db.query(AsignaturaProgramaCohorte).filter(
        AsignaturaProgramaCohorte.id == id
    ).first()

    if not asignatura_programa_cohorte:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Asignatura-Programa-Cohorte con ID {id} no encontrada"
        )

    # Convertir el objeto Pydantic a diccionario, excluyendo campos no enviados en la solicitud
    update_data_dict = asignatura_programa_cohorte_data.model_dump(exclude_unset=True)

    # 2. Validar existencia de relaciones (si los IDs se actualizan)
    if 'asignatura_programa_id' in update_data_dict:
        asignatura_programa = db.query(AsignaturaPrograma).filter(
            AsignaturaPrograma.id == update_data_dict['asignatura_programa_id']
        ).first()
        if not asignatura_programa:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Asignatura-Programa no encontrada")


    if 'salon_id' in update_data_dict:
        verificar_salon_existe(update_data_dict['salon_id'], db)
    
    if 'horario_id' in update_data_dict:
        horario_db = db.query(HorarioDB).filter(HorarioDB.id == update_data_dict['horario_id']).first()
        if not horario_db:
            raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Horario no encontrado")
            
    # 3. Actualizar los campos del objeto existente
    for key, value in update_data_dict.items():
        # Solo actualizar campos que existen en el modelo y que no son el ID
        if hasattr(asignatura_programa_cohorte, key) and key != 'id':
            setattr(asignatura_programa_cohorte, key, value)

    db.commit()
    db.refresh(asignatura_programa_cohorte)

    return asignatura_programa_cohorte