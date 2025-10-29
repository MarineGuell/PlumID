# api/main.py
from __future__ import annotations

import logging
import secrets
from pathlib import Path
from typing import Any, Dict, Optional

from fastapi import FastAPI, HTTPException, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import FileResponse, JSONResponse
from fastapi.staticfiles import StaticFiles

from api.settings import settings
from .middlewares.tracing import install_tracing

# Routes
from .routes.health import router as health_router
from .routes.species import router as species_router
from .routes.feathers import router as feathers_router
from .routes.pictures import router as pictures_router

log = logging.getLogger("uvicorn")

app = FastAPI(title="Plum'ID - API", version=settings.api_version)

# --- Tracing + CORS ---
install_tracing(app)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ========== Exception handlers ==========

def _problem_json(*, status: int, code: str, message: str, trace_id: str,
                  hint: Optional[str] = None, details: Optional[Dict[str, Any]] = None) -> JSONResponse:
    payload: Dict[str, Any] = {"error": {"code": code, "message": message, "trace_id": trace_id}}
    if hint: payload["error"]["hint"] = hint
    if details: payload["error"]["details"] = details
    return JSONResponse(status_code=status, content=payload)

@app.exception_handler(HTTPException)
async def http_exception_handler(request: Request, exc: HTTPException):
    trace = getattr(request.state, "trace_id", secrets.token_hex(8))
    msg = exc.detail if isinstance(exc.detail, str) else "HTTP error"
    return _problem_json(status=exc.status_code, code=f"HTTP_{exc.status_code}", message=msg, trace_id=trace)

@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    trace = getattr(request.state, "trace_id", secrets.token_hex(8))
    return _problem_json(status=422, code="VALIDATION_ERROR", message="Invalid request payload",
                         trace_id=trace, details={"errors": exc.errors()},
                         hint="Vérifie les champs requis et leurs types.")

@app.exception_handler(Exception)
async def unhandled_exception_handler(request: Request, exc: Exception):
    trace = getattr(request.state, "trace_id", secrets.token_hex(8))
    logging.exception("INTERNAL ERROR [trace=%s]: %s", trace, exc)
    return _problem_json(status=500, code="INTERNAL_ERROR", message="Unexpected server error",
                         trace_id=trace, hint="Consulte les logs serveur avec ce trace_id.")


# ========== Mount routers ==========
app.include_router(health_router)
app.include_router(species_router)
app.include_router(feathers_router)
app.include_router(pictures_router)