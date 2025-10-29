from __future__ import annotations
from sqlalchemy import Column, Integer, String, ForeignKey, Index
from sqlalchemy.orm import relationship
from api.models.base import Base

class Feathers(Base):
    __tablename__ = "feathers"
    idfeathers = Column(Integer, primary_key=True, index=True, autoincrement=True)
    side = Column(String(45))
    type = Column(String(45))
    body_zone = Column(String(45))

    species_idspecies = Column(Integer, ForeignKey("species.idspecies", ondelete="CASCADE", onupdate="CASCADE"), index=True)
    species = relationship("Species", backref="feathers", lazy="joined")

Index("idx_feathers_species", Feathers.species_idspecies)
