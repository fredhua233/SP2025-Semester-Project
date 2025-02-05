from typing import List
from bson import ObjectId
from app.models.moving_query import MovingQuery
from app.schemas.moving_query import MovingQuery as MovingQuerySchema

async def create_moving_query(db, moving_query: MovingQuerySchema):
    result = await db["moving_queries"].insert_one(moving_query.dict(by_alias=True))
    return str(result.inserted_id)

async def get_moving_query(db, id: str):
    return await db["moving_queries"].find_one({"_id": ObjectId(id)})

async def get_moving_queries(db) -> List[MovingQuery]:
    return await db["moving_queries"].find().to_list(1000)

async def update_moving_query(db, id: str, moving_query: MovingQuerySchema):
    await db["moving_queries"].update_one({"_id": ObjectId(id)}, {"$set": moving_query.dict(by_alias=True)})

async def delete_moving_query(db, id: str):
    await db["moving_queries"].delete_one({"_id": ObjectId(id)})
