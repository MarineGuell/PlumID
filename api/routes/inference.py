from __future__ import annotations

from fastapi import APIRouter, Depends, File, HTTPException, Request, UploadFile
from sqlalchemy import select
from sqlalchemy.orm import Session

from api.db import get_db
from api.models.species import Species
from api.schemas.inference import PredictResponse, PredictionItem, SpeciesMatched
from api.security.antireplay import require_signed_request
from api.services.image_classifier import ModelConfigurationError, get_classifier
from api.settings import settings

router = APIRouter(tags=["inference"])
_signed_guard = require_signed_request(settings)


async def maybe_require_signature(request: Request) -> None:
    if settings.inference_require_signature:
        await _signed_guard(request)


@router.post("/predict", response_model=PredictResponse, dependencies=[Depends(maybe_require_signature)])
async def predict_bird_from_image(
    request: Request,
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    content_type = (file.content_type or "").lower().strip()
    if content_type not in settings.allowed_image_mime_types_list:
        raise HTTPException(
            status_code=415,
            detail=f"Unsupported file type '{content_type}'. Types autorisés: {', '.join(settings.allowed_image_mime_types_list)}",
        )

    image_bytes = await file.read()
    if not image_bytes:
        raise HTTPException(status_code=400, detail="Empty file")

    try:
        classifier = get_classifier()
        predictions = classifier.predict(image_bytes=image_bytes, top_k=settings.inference_top_k)
    except ModelConfigurationError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc
    except Exception as exc:
        raise HTTPException(status_code=500, detail=f"Inference failed: {exc}") from exc

    if not predictions:
        raise HTTPException(status_code=500, detail="Le modèle n'a renvoyé aucune prédiction.")

    best = predictions[0]
    matched_species = None
    species_id = classifier.get_species_id(best.class_index)

    if species_id is not None:
        species_row = db.get(Species, species_id)
    else:
        species_row = db.execute(select(Species).where(Species.species_name == best.label)).scalar_one_or_none()

    if species_row is not None:
        matched_species = SpeciesMatched.model_validate(species_row)

    return PredictResponse(
        filename=file.filename or "image",
        mime_type=content_type,
        predicted_class_index=best.class_index,
        predicted_label=best.label,
        confidence=round(best.confidence, 6),
        top_k=[
            PredictionItem(
                class_index=item.class_index,
                label=item.label,
                confidence=round(item.confidence, 6),
            )
            for item in predictions
        ],
        matched_species=matched_species,
        trace_id=getattr(request.state, "trace_id", None),
    )
