import httpx
from sqlalchemy.orm import Session
from models.external.asignatura_programa import AsignaturaPrograma
from models.programa_model import Programa
from fastapi import HTTPException, status
from models.external.asignatura_model import AsignaturaDB

ASIGNATURAS_URL = "http://ms-asignaturas:8002/asignatura"  # URL del microservicio de asignaturas

# Función para verificar si la asignatura existe
def verificar_asignatura_existe(asignatura_id: int, db: Session):
    asignatura = db.query(AsignaturaDB).filter(AsignaturaDB.id == asignatura_id).first()
    if not asignatura:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"La asignatura con ID {asignatura_id} no existe en la base de datos."
        )

async def asignar_asignatura_programa(data, db: Session):
    #  Verificar si la asignatura existe usando el microservicio
    verificar_asignatura_existe(data.asignatura_id, db)

    #  Verificar si el programa existe localmente (porque estás en el microservicio de programas)
    programa_db = db.query(Programa).filter(Programa.id == data.programa_id).first()

    if not programa_db:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Programa no encontrado")

    # Verificar si ya existe la relación
    existe_relacion = db.query(AsignaturaPrograma).filter(
        AsignaturaPrograma.asignatura_id == data.asignatura_id,
        AsignaturaPrograma.programa_id == data.programa_id
    ).first()
    if existe_relacion:
        raise HTTPException(status_code=status.HTTP_409_CONFLICT, detail="La asignatura ya está asignada a este programa.")

    #  Crear la relación en la tabla puente
    asignatura_programa = AsignaturaPrograma(
        asignatura_id=data.asignatura_id,
        programa_id=data.programa_id
    )
    db.add(asignatura_programa)
    db.commit()
    db.refresh(asignatura_programa)
    
    return {"message": "Asignatura asignada al programa exitosamente", "data": asignatura_programa}


# Obtener todas las relaciones
def obtener_todas_asignaturas_programas(db: Session):
    relaciones = db.query(AsignaturaPrograma).all()
    return relaciones

#  Obtener una relación específica por id
def obtener_asignatura_programa_por_id(relacion_id: int, db: Session):
    relacion = db.query(AsignaturaPrograma).filter(AsignaturaPrograma.id == relacion_id).first()
    if not relacion:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Relación no encontrada")
    return relacion


def eliminar_asignatura_programa(relacion_id: int, db: Session):
    relacion = db.query(AsignaturaPrograma).filter(AsignaturaPrograma.id == relacion_id).first()
    if not relacion:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Relación no encontrada")
    
    db.delete(relacion)
    db.commit()
    return {"message": "Relación eliminada exitosamente"}