from __future__ import annotations

from typing import Any

from sqlalchemy import create_engine
from sqlalchemy.orm import Session, declarative_base, sessionmaker

from api.settings import settings

DB_URL = settings.db_url

POOL_KW: dict[str, Any] = {
    "pool_pre_ping": True,
    "pool_recycle": 280,
    "pool_size": settings.db_pool_size,
    "max_overflow": settings.db_max_overflow,
}

CONNECT_ARGS: dict[str, Any] = {}

if settings.mysql_ssl_ca and DB_URL.startswith("mysql"):
    CONNECT_ARGS["ssl"] = {"ca": settings.mysql_ssl_ca}

if DB_URL.startswith("sqlite"):
    CONNECT_ARGS["check_same_thread"] = False
    POOL_KW.pop("pool_size", None)
    POOL_KW.pop("max_overflow", None)
    POOL_KW.pop("pool_recycle", None)

engine = create_engine(DB_URL, connect_args=CONNECT_ARGS, **POOL_KW)
SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False, expire_on_commit=False)
Base = declarative_base()


def get_db():
    db: Session = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db() -> None:
    import api.models  # noqa: F401

    Base.metadata.create_all(bind=engine)
