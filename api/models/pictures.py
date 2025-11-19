from __future__ import annotations
from sqlalchemy import Column, Integer, String, Date, ForeignKey, Index
from sqlalchemy.orm import relationship
from api.models.base import Base

class Pictures(Base):
    __tablename__ = "pictures"
    idpictures = Column(Integer, primary_key=True, index=True, autoincrement=True)
    url = Column(String(255))
    longitude = Column(String(45))
    latitude = Column(String(45))
    date_collected = Column(Date)

    feathers_idfeathers = Column(Integer, ForeignKey("feathers.idfeathers", ondelete="CASCADE", onupdate="CASCADE"), index=True)
    feathers = relationship("Feathers", backref="pictures", lazy="joined")

Index("idx_pictures_feathers", Pictures.feathers_idfeathers)
