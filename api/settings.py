from __future__ import annotations

from pydantic import AliasChoices, Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    api_version: str = "2.0.0"
    log_level: str = Field(default="INFO", validation_alias=AliasChoices("LOG_LEVEL"))
    log_sensitive: bool = Field(default=False, validation_alias=AliasChoices("LOG_SENSITIVE"))

    plum_id_api_key: str = Field(
        default="MON_SUPER_TOKEN",
        validation_alias=AliasChoices("PLUMID_API_KEY", "PLUM_ID_API_KEY"),
        description="Bearer token pour appels service-to-service",
    )

    auth_secret: str = Field(
        default="PLEASE_CHANGE_ME",
        validation_alias=AliasChoices("AUTH_SECRET", "JWT_SECRET"),
        description="Secret HS256 pour signer les tokens d'accès",
    )
    access_token_expire_minutes: int = Field(
        default=60,
        validation_alias=AliasChoices("ACCESS_TOKEN_EXPIRE_MINUTES"),
    )

    cors_allow_origins: str = Field(
        default="*",
        validation_alias=AliasChoices("CORS_ALLOW_ORIGINS"),
    )

    database_url: str = Field(default="sqlite:///./app.db", validation_alias=AliasChoices("DATABASE_URL"))
    ip_db: str = Field(default="localhost", validation_alias=AliasChoices("IP_DB", "DB_HOST"))
    port_db: str = Field(default="3306", validation_alias=AliasChoices("PORT_DB", "DB_PORT"))
    user_db: str = Field(default="user", validation_alias=AliasChoices("USER_DB", "DB_USER"))
    password_db: str = Field(default="user", validation_alias=AliasChoices("MDP_DB", "DB_PASSWORD"))
    name_db: str = Field(default="plumid", validation_alias=AliasChoices("NAME_DB", "DB_NAME"))
    db_charset: str = Field(default="utf8mb4", validation_alias=AliasChoices("DB_CHARSET"))
    db_pool_size: int = Field(default=5, validation_alias=AliasChoices("DB_POOL_SIZE"))
    db_max_overflow: int = Field(default=10, validation_alias=AliasChoices("DB_MAX_OVERFLOW"))
    mysql_ssl_ca: str = Field(default="", validation_alias=AliasChoices("MYSQL_SSL_CA"))

    smtp_host: str = Field(default="localhost", validation_alias=AliasChoices("SMTP_HOST"))
    smtp_port: int = Field(default=25, validation_alias=AliasChoices("SMTP_PORT"))
    smtp_user: str = Field(default="", validation_alias=AliasChoices("SMTP_USER"))
    smtp_password: str = Field(default="", validation_alias=AliasChoices("SMTP_PASSWORD"))
    smtp_from: str = Field(default="no-reply@plumid.local", validation_alias=AliasChoices("SMTP_FROM"))

    frontend_base_url: str = Field(default="http://localhost:5173", validation_alias=AliasChoices("FRONTEND_BASE_URL"))

    rl_default_per_min: int = Field(60, validation_alias=AliasChoices("RL_DEFAULT_PER_MIN"))
    rl_burst: int = Field(120, validation_alias=AliasChoices("RL_BURST"))
    rl_login_per_min: int = Field(10, validation_alias=AliasChoices("RL_LOGIN_PER_MIN"))
    rl_window_seconds: int = Field(60, validation_alias=AliasChoices("RL_WINDOW_SECONDS"))

    app_hmac_secret: str = Field(
        default="CHANGE_ME_SUPER_SECRET",
        validation_alias=AliasChoices("APP_HMAC_SECRET"),
    )
    max_clock_skew_sec: int = Field(300, validation_alias=AliasChoices("MAX_CLOCK_SKEW_SEC"))
    anti_replay_ttl_sec: int = Field(600, validation_alias=AliasChoices("ANTI_REPLAY_TTL_SEC"))
    max_request_body_bytes: int = Field(5_000_000, validation_alias=AliasChoices("MAX_REQUEST_BODY_BYTES"))

    model_backend: str = Field(default="onnx", validation_alias=AliasChoices("MODEL_BACKEND"))
    model_path: str = Field(default="./models/bird_species.onnx", validation_alias=AliasChoices("MODEL_PATH"))
    class_names_path: str = Field(default="./models/class_names.json", validation_alias=AliasChoices("CLASS_NAMES_PATH"))
    inference_image_size: int = Field(default=224, validation_alias=AliasChoices("INFERENCE_IMAGE_SIZE"))
    inference_top_k: int = Field(default=3, validation_alias=AliasChoices("INFERENCE_TOP_K"))
    inference_require_signature: bool = Field(default=True, validation_alias=AliasChoices("INFERENCE_REQUIRE_SIGNATURE"))
    preload_model_on_startup: bool = Field(default=False, validation_alias=AliasChoices("PRELOAD_MODEL_ON_STARTUP"))
    fail_fast_on_startup: bool = Field(default=False, validation_alias=AliasChoices("FAIL_FAST_ON_STARTUP"))
    allowed_image_mime_types: str = Field(
        default="image/jpeg,image/png,image/webp",
        validation_alias=AliasChoices("ALLOWED_IMAGE_MIME_TYPES"),
    )
    image_mean: str = Field(default="0.485,0.456,0.406", validation_alias=AliasChoices("IMAGE_MEAN"))
    image_std: str = Field(default="0.229,0.224,0.225", validation_alias=AliasChoices("IMAGE_STD"))

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
        case_sensitive=False,
        protected_namespaces=("settings_",),
    )

    @property
    def cors_origins(self) -> list[str]:
        raw = (self.cors_allow_origins or "").strip()
        if not raw:
            return []
        return [s.strip() for s in raw.split(",") if s.strip()]

    @property
    def mysql_dsn(self) -> str:
        return (
            f"mysql+pymysql://{self.user_db}:{self.password_db}"
            f"@{self.ip_db}:{self.port_db}/{self.name_db}?charset={self.db_charset}"
        )

    @property
    def db_url(self) -> str:
        return self.database_url.strip() or self.mysql_dsn

    @property
    def allowed_image_mime_types_list(self) -> list[str]:
        return [s.strip().lower() for s in self.allowed_image_mime_types.split(",") if s.strip()]

    @property
    def image_mean_values(self) -> list[float]:
        return [float(v.strip()) for v in self.image_mean.split(",") if v.strip()]

    @property
    def image_std_values(self) -> list[float]:
        return [float(v.strip()) for v in self.image_std.split(",") if v.strip()]


settings = Settings()
