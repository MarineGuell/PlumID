# api/core/security.py
from __future__ import annotations

from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional

from jose import JWTError, jwt
from passlib.context import CryptContext

from api.settings import settings

ALGORITHM = "HS256"

# Contexte Passlib pour le hash des mots de passe
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")


def hash_password(password: str) -> str:
    """Hash un mot de passe avec bcrypt."""
    return pwd_context.hash(password)


def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Vérifie la correspondance mot de passe / hash."""
    return pwd_context.verify(plain_password, hashed_password)


def create_access_token(
    data: Dict[str, Any],
    expires_delta: Optional[timedelta] = None,
) -> str:
    """
    Crée un JWT signé HS256.

    data doit contenir au minimum un "sub" (string) = user_id.
    """
    to_encode = data.copy()

    if expires_delta is None:
        expires_delta = timedelta(minutes=settings.access_token_expire_minutes)

    expire = datetime.now(timezone.utc) + expires_delta
    to_encode.update({"exp": expire})

    encoded_jwt = jwt.encode(to_encode, settings.auth_secret, algorithm=ALGORITHM)
    return encoded_jwt


def decode_access_token(token: str) -> Dict[str, Any]:
    """
    Décode un JWT et retourne le payload.

    Lève JWTError si invalide ou expiré.
    """
    payload = jwt.decode(token, settings.auth_secret, algorithms=[ALGORITHM])
    return payload
