from typing import List
from bson import ObjectId
from app.models.moving_company import MovingCompany
from app.schemas.moving_company import MovingCompany as MovingCompanySchema

async def create_moving_company(db, moving_company: MovingCompanySchema):
    result = await db["moving_companies"].insert_one(moving_company.dict(by_alias=True))
    return str(result.inserted_id)

async def get_moving_company(db, id: str):
    return await db["moving_companies"].find_one({"_id": ObjectId(id)})

async def get_moving_companies(db) -> List[MovingCompany]:
    return await db["moving_companies"].find().to_list(1000)

async def update_moving_company(db, id: str, moving_company: MovingCompanySchema):
    await db["moving_companies"].update_one({"_id": ObjectId(id)}, {"$set": moving_company.dict(by_alias=True)})

async def delete_moving_company(db, id: str):
    await db["moving_companies"].delete_one({"_id": ObjectId(id)})
