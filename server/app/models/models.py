from sqlalchemy import Column, Integer, String, Boolean, Float
from sqlalchemy.orm import relationship
from app.database.database import Base
import datetime

class MovingQuery(Base):
    __tablename__ = 'moving_queries'

    id = Column(Integer, primary_key=True, index=True)
    location_from = Column(String, index=True)
    location_to = Column(String, index=True)
    date = Column(String)
    items = Column(String)
    quotes_found = Column(Boolean, default=False)
    moving_companies_count = Column(Integer)
    moving_company_ids = Column(String)
    phone_call_information_ids = Column(String)
    latitude_from = Column(Float)
    longitude_from = Column(Float)
    latitude_to = Column(Float)
    longitude_to = Column(Float)

class MovingCompany(Base):
    __tablename__ = 'moving_companies'

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    phone_number = Column(String, index=True)
    latitude = Column(Float)
    longitude = Column(Float)

class PhoneCalls(Base):
    __tablename__ = 'phone_calls'

    id = Column(Integer, primary_key=True, index=True)
    date = Column(String)
    duration = Column(Integer)
    transcript = Column(String)

    moving_query = relationship("MovingQuery", back_populates="phone_calls")
    moving_company_id = Column(Integer, index=True)

