# api/routes/auth.py
from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from api.core.security import create_access_token
from api.crud.users import authenticate_user, create_user, get_user_by_mail
from api.db import get_db
from api.dependencies.auth import get_current_user
from api.models.users import Users
from api.schemas.users import UserCreate, UserLogin, UserOut, Token

router = APIRouter(prefix="/auth", tags=["auth"])

@router.post("/register", response_model=UserOut, status_code=status.HTTP_201_CREATED)
def register(
    payload: UserCreate,
    db: Annotated[Session, Depends(get_db)],
) -> Users:
    """
    Inscription d'un nouvel utilisateur.

    - Vérifie l'unicité de l'email
    - Hash le mot de passe
    """
    existing = get_user_by_mail(db, mail=payload.mail)
    if existing is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Un utilisateur avec cet email existe déjà.",
        )

    user = create_user(
        db,
        mail=payload.mail,
        username=payload.username,
        password=payload.password,
    )
    return user


@router.post("/login", response_model=Token)
def login(
    payload: UserLogin,
    db: Annotated[Session, Depends(get_db)],
) -> Token:
    """
    Login utilisateur.

    Retourne un JWT Bearer en cas de succès.
    """
    user = authenticate_user(db, mail=payload.mail, password=payload.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email ou mot de passe invalide.",
        )

    token = create_access_token(
        data={
            "sub": str(user.idusers),
            "role": user.role or "user",
        }
    )
    return Token(access_token=token, token_type="bearer")


@router.get("/me", response_model=UserOut)
def read_me(
    current_user: Annotated[Users, Depends(get_current_user)],
) -> Users:
    """
    Retourne le profil de l'utilisateur courant (à partir du Bearer token).
    """
    return current_user
