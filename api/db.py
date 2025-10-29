# api/db.py
from __future__ import annotations

import os
from contextlib import contextmanager
from typing import Iterator, Optional, Dict, Any

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, declarative_base, Session

# Exemple MySQL attendu :
# DATABASE_URL="mysql+pymysql://user:password@host:3306/dbname?charset=utf8mb4"
DB_URL = os.getenv("DATABASE_URL", "sqlite:///./app.db")

# Options de pool raisonnables pour MySQL en prod
POOL_KW: Dict[str, Any] = {
    "pool_pre_ping": True,   # évite les connexions mortes
    "pool_recycle": 280,     # recycle avant le timeout par défaut de MySQL (8h); 280s utile derrière LB
    "pool_size": int(os.getenv("DB_POOL_SIZE", "5")),
    "max_overflow": int(os.getenv("DB_MAX_OVERFLOW", "10")),
}

CONNECT_ARGS: Dict[str, Any] = {}

# SSL optionnel (si cert fourni)
# MYSQL_SSL_CA=/path/to/ca.pem
ssl_ca = os.getenv("MYSQL_SSL_CA")
if ssl_ca and DB_URL.startswith("mysql"):
    CONNECT_ARGS["ssl"] = {"ca": ssl_ca}

# SQLite: connect_args spécifiques + pas de pool sizing
if DB_URL.startswith("sqlite"):
    CONNECT_ARGS.setdefault("check_same_thread", False)
    # Pour SQLite, pool_size/max_overflow sont ignorés par le dialecte
    POOL_KW.pop("pool_size", None)
    POOL_KW.pop("max_overflow", None)
    POOL_KW.pop("pool_recycle", None)

engine = create_engine(
    DB_URL,
    connect_args=CONNECT_ARGS,
    **POOL_KW,
)

SessionLocal = sessionmaker(bind=engine, autocommit=False, autoflush=False, expire_on_commit=False)
Base = declarative_base()


@contextmanager
def get_db() -> Iterator[Session]:
    """Dépendance FastAPI: yield une session SQLAlchemy proprement fermée."""
    db: Optional[Session] = None
    try:
        db = SessionLocal()
        yield db
    finally:
        if db is not None:
            db.close()
