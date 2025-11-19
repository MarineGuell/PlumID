from __future__ import annotations
from pydantic import BaseModel

class SpeciesBase(BaseModel):
    sex: str | None = None
    region: str | None = None
    environment: str | None = None
    information: str | None = None
    species_name: str | None = None

class SpeciesCreate(SpeciesBase): pass

class SpeciesOut(SpeciesBase):
    idspecies: int
    class Config: from_attributes = True
