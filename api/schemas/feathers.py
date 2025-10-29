from __future__ import annotations
from pydantic import BaseModel

class FeathersBase(BaseModel):
    side: str | None = None
    type: str | None = None
    body_zone: str | None = None
    species_idspecies: int | None = None

class FeathersCreate(FeathersBase): pass

class FeathersOut(FeathersBase):
    idfeathers: int
    class Config: from_attributes = True
