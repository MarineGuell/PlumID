from __future__ import annotations
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from api.db import get_db
from api.models.pictures import Pictures
from api.schemas.pictures import PicturesCreate, PicturesOut

router = APIRouter(prefix="/pictures", tags=["pictures"])

@router.post("", response_model=PicturesOut, status_code=201)
def create_picture(payload: PicturesCreate, db: Session = Depends(get_db)):
    obj = Pictures(**payload.dict())
    db.add(obj)
    db.commit()
    db.refresh(obj)
    return obj

@router.get("/{idpictures}", response_model=PicturesOut)
def get_picture(idpictures: int, db: Session = Depends(get_db)):
    obj = db.get(Pictures, idpictures)
    if not obj:
        raise HTTPException(status_code=404, detail="Picture not found")
    return obj

@router.delete("/{idpictures}", status_code=204)
def delete_picture(idpictures: int, db: Session = Depends(get_db)):
    obj = db.get(Pictures, idpictures)
    if not obj:
        raise HTTPException(status_code=404, detail="Picture not found")
    db.delete(obj)
    db.commit()
