from pydantic import BaseModel
from typing import Optional

class Salon(BaseModel):
    id: Optional[int] = None
    name: str

    class Config:
        schema_extra = {
            "example": {
                "name": "Salón nuevo"
            }
        }

salones = [
    Salon(id=1, name="salon 1"),
    Salon(id=2, name="salon 2"),
    Salon(id=3, name="salon 3"),
]


"""from pydantic import BaseModel

class Salon(BaseModel):
    id: int
    name: str

salones = [
    Salon(id=1,name="salon 1"),
    Salon(id=2,name="salon 2"),
    Salon(id=3,name="salon 3"),
]"""