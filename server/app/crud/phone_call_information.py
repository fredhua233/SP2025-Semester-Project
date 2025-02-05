from typing import List
from bson import ObjectId
from app.models.phone_call_information import PhoneCallInformation
from app.schemas.phone_call_information import PhoneCallInformation as PhoneCallInformationSchema

async def create_phone_call_information(db, phone_call_information: PhoneCallInformationSchema):
    result = await db["phone_call_information"].insert_one(phone_call_information.dict(by_alias=True))
    return str(result.inserted_id)

async def get_phone_call_information(db, id: str):
    return await db["phone_call_information"].find_one({"_id": ObjectId(id)})

async def get_phone_call_informations(db) -> List[PhoneCallInformation]:
    return await db["phone_call_information"].find().to_list(1000)

async def update_phone_call_information(db, id: str, phone_call_information: PhoneCallInformationSchema):
    await db["phone_call_information"].update_one({"_id": ObjectId(id)}, {"$set": phone_call_information.dict(by_alias=True)})

async def delete_phone_call_information(db, id: str):
    await db["phone_call_information"].delete_one({"_id": ObjectId(id)})
