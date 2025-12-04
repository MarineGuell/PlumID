# api/schemas/users.py
from __future__ import annotations

from typing import Optional
from datetime import datetime

from pydantic import BaseModel, EmailStr, ConfigDict, Field


class UserBase(BaseModel):
    mail: Optional[EmailStr] = None
    username: Optional[str] = None
    role: Optional[str] = None
    # Statut de vérification de l'email
    is_verified: Optional[bool] = None
    # Date/heure de vérification (UTC)
    email_verified_at: Optional[datetime] = None


class UserCreate(BaseModel):
    mail: EmailStr = Field(..., description="Adresse mail de l'utilisateur")
    username: str = Field(..., min_length=3, max_length=100)
    password: str = Field(
        ...,
        min_length=8,
        max_length=128,
        description="Mot de passe en clair",
    )


class UserLogin(BaseModel):
    mail: EmailStr
    password: str


class UserOut(UserBase):
    idusers: int

    # Permet de mapper directement depuis un objet SQLAlchemy Users
    model_config = ConfigDict(from_attributes=True)


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenPayload(BaseModel):
    # Identifiant utilisateur (string dans le payload JWT)
    sub: Optional[str] = None
    role: Optional[str] = None
    exp: Optional[int] = None
    # Scope du token : ex. "access" ou "email_verify"
    scope: Optional[str] = None
