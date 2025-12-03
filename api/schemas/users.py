# api/schemas/users.py
from __future__ import annotations

from typing import Optional

from pydantic import BaseModel, EmailStr, ConfigDict, Field


class UserBase(BaseModel):
    mail: Optional[EmailStr] = None
    username: Optional[str] = None
    role: Optional[str] = None


class UserCreate(BaseModel):
    mail: EmailStr = Field(..., description="Adresse mail de l'utilisateur")
    username: str = Field(..., min_length=3, max_length=100)
    password: str = Field(..., min_length=8, max_length=128, description="Mot de passe en clair")


class UserLogin(BaseModel):
    mail: EmailStr
    password: str


class UserOut(UserBase):
    idusers: int

    model_config = ConfigDict(from_attributes=True)


class Token(BaseModel):
    access_token: str
    token_type: str = "bearer"


class TokenPayload(BaseModel):
    sub: Optional[str] = None  # user id (string)
    role: Optional[str] = None
    exp: Optional[int] = None
