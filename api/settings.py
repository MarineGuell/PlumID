# api/settings.py
from __future__ import annotations

from pydantic import Field, AliasChoices
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    # ---------------------------
    # API / Logging
    # ---------------------------
    api_version: str = "1.0.0"
    log_level: str = Field(default="INFO", validation_alias=AliasChoices("LOG_LEVEL"))
    log_sensitive: bool = Field(default=False, validation_alias=AliasChoices("LOG_SENSITIVE"))

    # ---------------------------
    # Auth (API key service-to-service)
    # ---------------------------
    plum_id_api_key: str = Field(
        default="MON_SUPER_TOKEN",
        validation_alias=AliasChoices("PLUMID_API_KEY"),
        description="Bearer token pour appels service-to-service",
    )

    # ---------------------------
    # Auth (comptes + JWT)
    # ---------------------------
    auth_secret: str = Field(
        default="PLEASE_CHANGE_ME",
        validation_alias=AliasChoices("AUTH_SECRET", "JWT_SECRET"),
        description="Secret HS256 pour signer les tokens d'accès",
    )
    access_token_expire_minutes: int = Field(
        default=60,
        validation_alias=AliasChoices("ACCESS_TOKEN_EXPIRE_MINUTES"),
        description="Durée (minutes) du token d'accès",
    )

    # ---------------------------
    # CORS (dev: * / prod: domaines)
    # ---------------------------
    cors_allow_origins: str = Field(
        default="*",
        validation_alias=AliasChoices("CORS_ALLOW_ORIGINS"),
        description="CSV de domaines autorisés, ex: https://exemple.com,https://studio.local",
    )

    # ---------------------------
    # DB (MySQL) — 2 modes :
    # 1) DATABASE_URL (recommandé, ex: mysql+pymysql://user:pass@host:3306/db?charset=utf8mb4)
    # 2) Construction à partir des champs ci-dessous si DATABASE_URL vide
    # ---------------------------
    database_url: str = Field(default="", validation_alias=AliasChoices("DATABASE_URL"))

    ip_db: str = Field(default="localhost", validation_alias=AliasChoices("IP_DB", "DB_HOST"))
    port_db: str = Field(default="3306", validation_alias=AliasChoices("PORT_DB", "DB_PORT"))
    user_db: str = Field(default="user", validation_alias=AliasChoices("USER_DB", "DB_USER"))
    password_db: str = Field(default="user", validation_alias=AliasChoices("MDP_DB", "DB_PASSWORD"))
    name_db: str = Field(default="plumid", validation_alias=AliasChoices("NAME_DB", "DB_NAME"))
    db_charset: str = Field(default="utf8mb4", validation_alias=AliasChoices("DB_CHARSET"))

    # Pool & SSL (optionnels)
    db_pool_size: int = Field(default=5, validation_alias=AliasChoices("DB_POOL_SIZE"))
    db_max_overflow: int = Field(default=10, validation_alias=AliasChoices("DB_MAX_OVERFLOW"))
    mysql_ssl_ca: str = Field(default="", validation_alias=AliasChoices("MYSQL_SSL_CA"))

    # ---------------------------
    # pydantic-settings v2
    # ---------------------------
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
        protected_namespaces=("settings_",),
    )

    # ---------------------------
    # Helpers
    # ---------------------------
    @property
    def cors_origins(self) -> list[str]:
        raw = (self.cors_allow_origins or "").strip()
        if not raw:
            return []
        return [s.strip() for s in raw.split(",") if s.strip()]

    @property
    def mysql_dsn(self) -> str:
        # DSN sans driver -> on uniformise avec PyMySQL
        return (
            f"mysql+pymysql://{self.user_db}:{self.password_db}"
            f"@{self.ip_db}:{self.port_db}/{self.name_db}?charset={self.db_charset}"
        )

    @property
    def db_url(self) -> str:
        # Privilégie DATABASE_URL si fourni, sinon construit un DSN MySQL complet
        return self.database_url.strip() or self.mysql_dsn


settings = Settings()
