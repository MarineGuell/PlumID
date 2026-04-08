from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from api.db import get_db
from api.models.species import Species
from api.schemas.species import SpeciesCreate, SpeciesOut

router = APIRouter(prefix="/species", tags=["species"])


@router.post("", response_model=SpeciesOut, status_code=201)
def create_species(payload: SpeciesCreate, db: Session = Depends(get_db)):
    obj = Species(**payload.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj


@router.get("", response_model=list[SpeciesOut])
def list_species(
    limit: int = Query(default=100, ge=1, le=500),
    offset: int = Query(default=0, ge=0),
    db: Session = Depends(get_db),
):
    stmt = select(Species).order_by(Species.idspecies).offset(offset).limit(limit)
    return list(db.execute(stmt).scalars().all())


@router.get("/{idspecies}", response_model=SpeciesOut)
def get_species(idspecies: int, db: Session = Depends(get_db)):
    obj = db.get(Species, idspecies)
    if not obj:
        raise HTTPException(status_code=404, detail="Species not found")
    return obj


@router.delete("/{idspecies}", status_code=204)
def delete_species(idspecies: int, db: Session = Depends(get_db)):
    obj = db.get(Species, idspecies)
    if not obj:
        raise HTTPException(status_code=404, detail="Species not found")
    db.delete(obj)
    db.commit()
