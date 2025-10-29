from __future__ import annotations
from sqlalchemy import Column, Integer, String
from api.models.base import Base

class Species(Base):
    __tablename__ = "species"
    idspecies = Column(Integer, primary_key=True, index=True, autoincrement=True)
    sex = Column(String(45))
    region = Column(String(45))
    environment = Column(String(45))
    information = Column(String(255))
    species_name = Column(String(100))
