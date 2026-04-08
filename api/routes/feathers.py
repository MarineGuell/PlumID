from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from api.db import get_db
from api.models.feathers import Feathers
from api.schemas.feathers import FeathersCreate, FeathersOut

router = APIRouter(prefix="/feathers", tags=["feathers"])


@router.post("", response_model=FeathersOut, status_code=201)
def create_feathers(payload: FeathersCreate, db: Session = Depends(get_db)):
    obj = Feathers(**payload.model_dump(exclude_unset=True))
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj


@router.get("", response_model=list[FeathersOut])
def list_feathers(
    limit: int = Query(default=100, ge=1, le=500),
    offset: int = Query(default=0, ge=0),
    db: Session = Depends(get_db),
):
    stmt = select(Feathers).order_by(Feathers.idfeathers).offset(offset).limit(limit)
    return list(db.execute(stmt).scalars().all())


@router.get("/{idfeathers}", response_model=FeathersOut)
def get_feathers(idfeathers: int, db: Session = Depends(get_db)):
    obj = db.get(Feathers, idfeathers)
    if not obj:
        raise HTTPException(status_code=404, detail="Feathers not found")
    return obj


@router.delete("/{idfeathers}", status_code=204)
def delete_feathers(idfeathers: int, db: Session = Depends(get_db)):
    obj = db.get(Feathers, idfeathers)
    if not obj:
        raise HTTPException(status_code=404, detail="Feathers not found")
    db.delete(obj)
    db.commit()
