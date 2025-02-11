from sqlalchemy import Column, Integer, String, Boolean
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
    moving_companies = Column(String) 
    phone_call_information_ids = Column(String)  


class MovingCompany(Base):
    __tablename__ = 'moving_companies'

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, index=True)
    phone_number = Column(String, index=True)

class PhoneCalls(Base):
    __tablename__ = 'phone_calls'

    id = Column(Integer, primary_key=True, index=True)
    date = Column(String)
    duration = Column(Integer)
    transcript = Column(String)

    moving_query = relationship("MovingQuery", back_populates="phone_calls")
    moving_company_id = Column(Integer, index=True)

