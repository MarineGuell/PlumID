from __future__ import annotations

import time

from fastapi import APIRouter

from api.services.image_classifier import ModelConfigurationError, get_classifier
from api.settings import settings

router = APIRouter(tags=["health"])


@router.get("/health")
async def health():
    t0 = time.perf_counter()

    model_ready = False
    model_error = None
    try:
        get_classifier()
        model_ready = True
    except ModelConfigurationError as exc:
        model_error = str(exc)
    except Exception as exc:
        model_error = f"Unexpected model error: {exc}"

    dt = (time.perf_counter() - t0) * 1000
    return {
        "status": "ok",
        "latency_ms": round(dt, 1),
        "model_backend": settings.model_backend,
        "model_ready": model_ready,
        "model_error": model_error,
    }
