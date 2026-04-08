from __future__ import annotations

from pydantic import BaseModel


class SpeciesMatched(BaseModel):
    idspecies: int
    species_name: str | None = None
    sex: str | None = None
    region: str | None = None
    environment: str | None = None
    information: str | None = None

    class Config:
        from_attributes = True


class PredictionItem(BaseModel):
    class_index: int
    label: str
    confidence: float


class PredictResponse(BaseModel):
    filename: str
    mime_type: str
    predicted_class_index: int
    predicted_label: str
    confidence: float
    top_k: list[PredictionItem]
    matched_species: SpeciesMatched | None = None
    trace_id: str | None = None