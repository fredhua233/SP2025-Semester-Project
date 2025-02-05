from fastapi import APIRouter, Depends
from typing import List
from app.schemas.moving_query import MovingQuery
from app.crud.moving_query import (
    create_moving_query,
    get_moving_query,
    get_moving_queries,
    update_moving_query,
    delete_moving_query
)
from app.dependencies import get_db

router = APIRouter()

@router.post("/", response_model=str)
async def create_moving_query_endpoint(moving_query: MovingQuery, db=Depends(get_db)):
    return await create_moving_query(db, moving_query)

@router.get("/{id}", response_model=MovingQuery)
async def get_moving_query_endpoint(id: str, db=Depends(get_db)):
    return await get_moving_query(db, id)

@router.get("/", response_model=List[MovingQuery])
async def get_moving_queries_endpoint(db=Depends(get_db)):
    return await get_moving_queries(db)

@router.put("/{id}")
async def update_moving_query_endpoint(id: str, moving_query: MovingQuery, db=Depends(get_db)):
    await update_moving_query(db, id, moving_query)
    return {"message": "Moving query updated successfully"}

@router.delete("/{id}")
async def delete_moving_query_endpoint(id: str, db=Depends(get_db)):
    await delete_moving_query(db, id)
    return {"message": "Moving query deleted successfully"}
