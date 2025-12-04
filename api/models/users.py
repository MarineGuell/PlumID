# api/models/users.py
from __future__ import annotations

from sqlalchemy import (
    Column,
    Integer,
    String,
    DateTime,
    func,
    Boolean,
    ForeignKey,
    Index,
    UniqueConstraint,
)
from sqlalchemy.orm import relationship

from api.models.base import Base


class Users(Base):
    __tablename__ = "users"

    idusers = Column(Integer, primary_key=True, index=True, autoincrement=True)
    password_hash = Column(String(255), nullable=False)
    role = Column(String(45))
    mail = Column(String(255), nullable=False)
    created_at = Column(
        DateTime,
        server_default=func.current_timestamp(),
        nullable=False,
    )
    username = Column(String(100))

    pictures_idpictures = Column(
        Integer,
        ForeignKey(
            "pictures.idpictures",
            ondelete="SET NULL",
            onupdate="CASCADE",
        ),
        nullable=True,
        index=True,
    )

    # --- Nouveau : statut de vérification de l'email ---
    is_verified = Column(
        Boolean,
        nullable=False,
        server_default="0",  # MySQL: TINYINT(1) par défaut
    )
    email_verified_at = Column(
        DateTime,
        nullable=True,
    )

    # --- Nouveau : statut d'activation du compte ---
    is_active = Column(
        Boolean,
        nullable=False,
        server_default="1",
    )

    # Relations
    picture = relationship("Pictures", lazy="joined")

    __table_args__ = (
        UniqueConstraint("mail", name="uniq_users_mail"),
        Index("idx_users_pictures", "pictures_idpictures"),
    )
