from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List

class MovingQuery(BaseModel):
    location_from: str
    location_to: str
    created_at: datetime
    items: str
    items_details: str
    availability: str
    user_id: str
    # inquiries: List[str]

class MovingInquiry(BaseModel):
    moving_company_id: int
    created_at: datetime 
    price: float #-1 if not yet found or price once found
    phone_call_transcript: str
    moving_query_id: int

class MovingCompany(BaseModel):
    name: str
    phone_number: str
    latitude: float
    longitude: float
    address: str
    rating: float
    user_ratings_total: int



class MovingQueryCreate(MovingQuery):
    pass


class MovingCompanyBase(BaseModel):
    name: str
    phone_number: str
    latitude: float
    longitude: float

class MovingCompanyCreate(MovingCompanyBase):
    pass

class MovingCompany(MovingCompanyBase):
    id: int

    class Config:
        orm_mode: True

class PhoneCallBase(BaseModel):
    date: str
    duration: int
    transcript: str
    moving_company_id: int

class PhoneCallCreate(PhoneCallBase):
    pass

class PhoneCall(PhoneCallBase):
    id: int

    class Config:
        orm_mode: True

