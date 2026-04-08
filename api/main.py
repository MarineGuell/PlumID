from __future__ import annotations

import logging
import secrets
from contextlib import asynccontextmanager
from typing import Any

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from api.db import init_db
from api.middlewares.body_limit import BodySizeLimitMiddleware
from api.middlewares.rate_limit import RateLimitMiddleware
from api.middlewares.tracing import install_tracing
from api.routes.auth import router as auth_router
from api.routes.feathers import router as feathers_router
from api.routes.health import router as health_router
from api.routes.inference import router as inference_router
from api.routes.pictures import router as pictures_router
from api.routes.species import router as species_router
from api.services.image_classifier import get_classifier
from api.settings import settings

log = logging.getLogger("uvicorn")


@asynccontextmanager
async def lifespan(_: FastAPI):
    init_db()
    if settings.preload_model_on_startup or settings.fail_fast_on_startup:
        try:
            get_classifier()
            log.info("Inference model loaded successfully")
        except Exception:
            log.exception("Failed to load inference model on startup")
            if settings.fail_fast_on_startup:
                raise
    yield


app = FastAPI(title="Plum'ID - API", version=settings.api_version, lifespan=lifespan)
install_tracing(app)

app.add_middleware(BodySizeLimitMiddleware, max_bytes=settings.max_request_body_bytes)

_redis = None
app.add_middleware(RateLimitMiddleware, settings=settings, redis=_redis)

allow_origins = settings.cors_origins or ["*"]
allow_credentials = False if allow_origins == ["*"] else True
app.add_middleware(
    CORSMiddleware,
    allow_origins=allow_origins,
    allow_methods=["*"],
    allow_headers=["*"],
    allow_credentials=allow_credentials,
)


def _problem_json(
    *,
    status: int,
    code: str,
    message: str,
    trace_id: str,
    hint: str | None = None,
    details: dict[str, Any] | None = None,
) -> JSONResponse:
    payload: dict[str, Any] = {"error": {"code": code, "message": message, "trace_id": trace_id}}
    if hint:
        payload["error"]["hint"] = hint
    if details:
        payload["error"]["details"] = details
    return JSONResponse(status_code=status, content=payload)


@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    trace = getattr(request.state, "trace_id", secrets.token_hex(8))
    msg = exc.detail if isinstance(exc.detail, str) else "HTTP error"
    return _problem_json(status=exc.status_code, code=f"HTTP_{exc.status_code}", message=msg, trace_id=trace)


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    trace = getattr(request.state, "trace_id", secrets.token_hex(8))
    return _problem_json(
        status=422,
        code="VALIDATION_ERROR",
        message="Invalid request payload",
        trace_id=trace,
        details={"errors": exc.errors()},
        hint="Vérifie les champs requis et leurs types.",
    )


@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    trace = getattr(request.state, "trace_id", secrets.token_hex(8))
    logging.exception("INTERNAL ERROR [trace=%s]: %s", trace, exc)
    return _problem_json(
        status=500,
        code="INTERNAL_ERROR",
        message="Unexpected server error",
        trace_id=trace,
        hint="Consulte les logs serveur avec ce trace_id.",
    )


app.include_router(health_router)
app.include_router(inference_router)
app.include_router(species_router)
app.include_router(feathers_router)
app.include_router(pictures_router)
app.include_router(auth_router)
