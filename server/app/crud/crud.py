from sqlalchemy.orm import Session
from app.models import models
from app.schemas import schemas

# CRUD functions for MovingQuery
def get_moving_query(db: Session, query_id: int):
    return db.query(models.MovingQuery).filter(models.MovingQuery.id == query_id).first()

def get_moving_queries(db: Session, skip: int = 0, limit: int = 10):
    return db.query(models.MovingQuery).offset(skip).limit(limit).all()

def create_moving_query(db: Session, moving_query: schemas.MovingQueryCreate):
    db_moving_query = models.MovingQuery(**moving_query.dict())
    db.add(db_moving_query)
    db.commit()
    db.refresh(db_moving_query)
    return db_moving_query

# CRUD functions for MovingCompany
def get_moving_company(db: Session, company_id: int):
    return db.query(models.MovingCompany).filter(models.MovingCompany.id == company_id).first()

def get_moving_companies(db: Session, skip: int = 0, limit: int = 10):
    return db.query(models.MovingCompany).offset(skip).limit(limit).all()

def create_moving_company(db: Session, moving_company: schemas.MovingCompanyCreate):
    db_moving_company = models.MovingCompany(**moving_company.dict())
    db.add(db_moving_company)
    db.commit()
    db.refresh(db_moving_company)
    return db_moving_company

# CRUD functions for PhoneCalls
def get_phone_call(db: Session, call_id: int):
    return db.query(models.PhoneCalls).filter(models.PhoneCalls.id == call_id).first()

def get_phone_calls(db: Session, skip: int = 0, limit: int = 10):
    return db.query(models.PhoneCalls).offset(skip).limit(limit).all()

def create_phone_call(db: Session, phone_call: schemas.PhoneCallCreate):
    db_phone_call = models.PhoneCalls(**phone_call.dict())
    db.add(db_phone_call)
    db.commit()
    db.refresh(db_phone_call)
    return db_phone_call
