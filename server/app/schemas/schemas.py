from pydantic import BaseModel
from datetime import datetime
from typing import Optional, List

class MovingQueryBase(BaseModel):
    location_from: str
    location_to: str
    date: str
    items: str
    quotes_found: bool
    moving_companies_count: int
    moving_companies: str
    phone_call_information_ids: str
    latitude_from: float
    longitude_from: float
    latitude_to: float
    longitude_to: float
    availability: str

class MovingQueryCreate(MovingQueryBase):
    pass

class MovingQuery(MovingQueryBase):
    id: int

    class Config:
        orm_mode: True

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

