from pydantic import BaseModel, Field
from typing import List
from bson import ObjectId

class MovingQuery(BaseModel):
    id: ObjectId = Field(default_factory=ObjectId, alias="_id")
    location_from: str
    location_to: str
    date: str
    items: str
    quotes_found: bool
    moving_companies_count: int
    moving_companies: List[ObjectId]
    phone_call_information_ids: List[ObjectId]

    class Config:
        allow_population_by_field_name = True
        arbitrary_types_allowed = True
        json_encoders = {ObjectId: str}
