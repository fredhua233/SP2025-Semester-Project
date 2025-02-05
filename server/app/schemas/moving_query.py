from pydantic import BaseModel
from typing import List

class MovingQuery(BaseModel):
    location_from: str
    location_to: str
    date: str
    items: str
    quotes_found: bool
    moving_companies_count: int
    moving_companies: List[str]
    phone_call_information_ids: List[str]
