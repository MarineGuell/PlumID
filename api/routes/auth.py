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
    create_password_reset_token,
    decode_access_token,
)
from api.crud.users import (
    authenticate_user,
    create_user,
    get_user_by_mail,
    get_user_by_id,
    update_user_password,
)
from api.db import get_db
from api.dependencies.auth import get_current_user
from api.models.users import Users
from api.schemas.users import (
    UserCreate,
    UserLogin,
    UserOut,
    Token,
    PasswordResetRequest,
    PasswordResetConfirm,
)
from api.services.email import send_verification_email, send_password_reset_email
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

    # Lien de vérification (frontend)
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


@router.post("/request-password-reset")
def request_password_reset(
    payload: PasswordResetRequest,
    db: Annotated[Session, Depends(get_db)],
):
    """
    Demande de réinitialisation de mot de passe.

    - Cherche l'utilisateur par email
    - Si trouvé, génère un token scope='password_reset'
      et envoie un email avec un lien de réinitialisation.
    - Toujours renvoyer un message générique (pour ne pas leak l'existence d'un compte).
    """
    user = get_user_by_mail(db, mail=payload.mail)

    if user:
        try:
            token = create_password_reset_token(user_id=user.idusers, expires_minutes=60)
            reset_link = f"{FRONTEND_BASE_URL}/reset-password?token={token}"
            send_password_reset_email(user.mail, reset_link)
            logger.info("Email de reset de mot de passe envoyé à %s", user.mail)
        except Exception:
            logger.exception(
                "Échec de l'envoi de l'email de reset de mot de passe à %s", user.mail
            )
            # On NE renvoie pas d'erreur explicite au client pour éviter le leak.

    return {
        "message": (
            "Si un compte existe pour cet email, un lien de réinitialisation a été envoyé."
        )
    }


@router.post("/reset-password")
def reset_password(
    payload: PasswordResetConfirm,
    db: Annotated[Session, Depends(get_db)],
):
    """
    Applique la réinitialisation de mot de passe.

    - Vérifie et décode le token (scope='password_reset')
    - Met à jour le mot de passe de l'utilisateur
    """
    from jose import JWTError

    try:
        token_payload = decode_access_token(payload.token)
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Token de réinitialisation invalide ou expiré.",
        )

    scope = token_payload.get("scope")
    sub = token_payload.get("sub")

    if scope != "password_reset" or sub is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Token de réinitialisation invalide.",
        )

    try:
        user_id = int(sub)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Token de réinitialisation invalide.",
        )

    user = get_user_by_id(db, user_id=user_id)
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Utilisateur introuvable.",
        )

    # Met à jour le mot de passe
    update_user_password(db, user=user, new_password=payload.new_password)

    return {"message": "Mot de passe mis à jour avec succès."}
