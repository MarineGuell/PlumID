from __future__ import annotations
from pydantic import BaseModel
from datetime import date

class PicturesBase(BaseModel):
    url: str | None = None
    longitude: str | None = None
    latitude: str | None = None
    date_collected: date | None = None
    feathers_idfeathers: int | None = None

class PicturesCreate(PicturesBase): pass

class PicturesOut(PicturesBase):
    idpictures: int
    class Config: from_attributes = True
