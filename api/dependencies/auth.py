# api/dependencies/auth.py
from __future__ import annotations

from typing import Annotated

from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer
from sqlalchemy.orm import Session

from api.core.security import decode_access_token
from api.db import get_db
from api.schemas.users import TokenPayload
from api.crud.users import get_user_by_id
from api.models.users import Users

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="auth/login")


def _credentials_exception() -> HTTPException:
    return HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )


def _get_token_payload(token: str) -> TokenPayload:
    from jose import JWTError  # import local pour éviter cycles

    try:
        payload_dict = decode_access_token(token)
    except JWTError:
        raise _credentials_exception()

    try:
        payload = TokenPayload(**payload_dict)
    except Exception:
        raise _credentials_exception()

    if payload.sub is None:
        raise _credentials_exception()

    return payload


def get_current_user(
    db: Annotated[Session, Depends(get_db)],
    token: Annotated[str, Depends(oauth2_scheme)],
) -> Users:
    """Dépendance FastAPI: retourne l'utilisateur courant à partir du Bearer token."""
    payload = _get_token_payload(token)

    try:
        user_id = int(payload.sub)
    except ValueError:
        raise _credentials_exception()

    user = get_user_by_id(db, user_id=user_id)
    if user is None:
        raise _credentials_exception()

    return user
