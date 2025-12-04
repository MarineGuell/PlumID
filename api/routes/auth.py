# api/routes/auth.py
from __future__ import annotations

from datetime import datetime, timezone
from typing import Annotated
import logging

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from api.core.security import (
    create_access_token,
    create_email_verification_token,
    decode_access_token,
)
from api.crud.users import (
    authenticate_user,
    create_user,
    get_user_by_mail,
    get_user_by_id,
)
from api.db import get_db
from api.dependencies.auth import get_current_user
from api.models.users import Users
from api.schemas.users import UserCreate, UserLogin, UserOut, Token
from api.services.email import send_verification_email
from api.settings import settings

router = APIRouter(prefix="/auth", tags=["auth"])

logger = logging.getLogger(__name__)

# On normalise l'URL de base du frontend (on enlève le / final pour éviter les //)
FRONTEND_BASE_URL = settings.frontend_base_url.rstrip("/")


@router.post("/register", response_model=UserOut, status_code=status.HTTP_201_CREATED)
def register(
    payload: UserCreate,
    db: Annotated[Session, Depends(get_db)],
) -> Users:
    """
    Inscription d'un nouvel utilisateur.

    - Vérifie l'unicité de l'email
    - Hash le mot de passe
    - Crée un compte non vérifié (is_verified = False)
    - Envoie un email de vérification
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

    # Génération du token de vérification (valide 24h)
    token = create_email_verification_token(user_id=user.idusers, expires_hours=24)

    # Lien de vérification.
    # Ici on part du principe que le frontend a une page /verify-email
    # qui lira le token dans l'URL et appellera ensuite l'API si besoin.
    verification_link = f"{FRONTEND_BASE_URL}/verify-email?token={token}"

    # Envoi de l'email
    try:
        send_verification_email(user.mail, verification_link)
        logger.info("Email de vérification envoyé à %s", user.mail)
    except Exception:
        # On ne bloque pas l'inscription si l'email foire, mais on log.
        logger.exception(
            "Échec de l'envoi de l'email de vérification à %s", user.mail
        )
        # À toi de décider: raise pour bloquer, ou juste log (ici on log seulement)
        # raise HTTPException(
        #     status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        #     detail="Impossible d'envoyer l'email de vérification.",
        # )

    return user


@router.post("/login", response_model=Token)
def login(
    payload: UserLogin,
    db: Annotated[Session, Depends(get_db)],
) -> Token:
    """
    Login utilisateur.

    - Vérifie mail + mot de passe
    - Vérifie que l'email est confirmé (is_verified)
    - Retourne un JWT Bearer en cas de succès
    """
    user = authenticate_user(db, mail=payload.mail, password=payload.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Email ou mot de passe invalide.",
        )

    if not user.is_verified:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Adresse email non vérifiée. Merci de vérifier ton email.",
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


@router.get("/verify-email")
def verify_email(token: str, db: Annotated[Session, Depends(get_db)]):
    """
    Vérifie l'adresse email à partir du token envoyé par mail.

    - Décodage du token
    - Vérification du scope 'email_verify'
    - Mise à jour is_verified + email_verified_at
    """
    from jose import JWTError

    try:
        payload = decode_access_token(token)
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Token de vérification invalide ou expiré.",
        )

    scope = payload.get("scope")
    sub = payload.get("sub")

    if scope != "email_verify" or sub is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Token de vérification invalide.",
        )

    try:
        user_id = int(sub)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Token de vérification invalide.",
        )

    user = get_user_by_id(db, user_id=user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Utilisateur introuvable.",
        )

    if user.is_verified:
        return {"message": "Adresse email déjà vérifiée."}

    user.is_verified = True
    user.email_verified_at = datetime.now(timezone.utc)
    db.commit()
    db.refresh(user)

    return {"message": "Adresse email vérifiée avec succès."}
