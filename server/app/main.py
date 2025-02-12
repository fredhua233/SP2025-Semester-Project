from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from app.models import models
from app.schemas import schemas
from app.crud import crud
from app.services import services
from app.database.database import SessionLocal, engine

models.Base.metadata.create_all(bind=engine)

app = FastAPI()

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.post("/get_moving_companies/")
async def get_moving_companies(moving_query: schemas.MovingQueryBase, db: Session = Depends(get_db)):
    return await services.get_moving_companies(moving_query=moving_query, db=db)

@app.post("/call_moving_companies/")
async def call_moving_companies(moving_query: schemas.MovingQueryBase, moving_company_number: str, db: Session = Depends(get_db)):
    return await services.create_phone_call(moving_company_number=moving_company_number, items=moving_query.items, availability=moving_query.availability, from_location=moving_query.location_from, to_location=moving_query.location_to)

#===============================================================================
# MovingQuery routes

@app.get("/moving_queries/{query_id}", response_model=schemas.MovingQuery)
def read_moving_query(query_id: int, db: Session = Depends(get_db)):
    db_moving_query = crud.get_moving_query(db, query_id=query_id)
    if db_moving_query is None:
        raise HTTPException(status_code=404, detail="Moving query not found")
    return db_moving_query

@app.put("/moving_queries/{query_id}", response_model=schemas.MovingQuery)
def update_moving_query(query_id: int, moving_query: schemas.MovingQueryCreate, db: Session = Depends(get_db)):
    return crud.update_moving_query(db=db, query_id=query_id, moving_query=moving_query)

@app.delete("/moving_queries/{query_id}", response_model=schemas.MovingQuery)
def delete_moving_query(query_id: int, db: Session = Depends(get_db)):
    return crud.delete_moving_query(db=db, query_id=query_id)

# MovingCompany routes
@app.post("/moving_companies/", response_model=schemas.MovingCompany)
def create_moving_company(moving_company: schemas.MovingCompanyCreate, db: Session = Depends(get_db)):
    return crud.create_moving_company(db=db, moving_company=moving_company)

@app.get("/moving_companies/{company_id}", response_model=schemas.MovingCompany)
def read_moving_company(company_id: int, db: Session = Depends(get_db)):
    db_moving_company = crud.get_moving_company(db, company_id=company_id)
    if db_moving_company is None:
        raise HTTPException(status_code=404, detail="Moving company not found")
    return db_moving_company

@app.put("/moving_companies/{company_id}", response_model=schemas.MovingCompany)
def update_moving_company(company_id: int, moving_company: schemas.MovingCompanyCreate, db: Session = Depends(get_db)):
    return crud.update_moving_company(db=db, company_id=company_id, moving_company=moving_company)

@app.delete("/moving_companies/{company_id}", response_model=schemas.MovingCompany)
def delete_moving_company(company_id: int, db: Session = Depends(get_db)):
    return crud.delete_moving_company(db=db, company_id=company_id)

# PhoneCalls routes
@app.post("/phone_calls/", response_model=schemas.PhoneCall)
def create_phone_call(phone_call: schemas.PhoneCallCreate, db: Session = Depends(get_db)):
    return crud.create_phone_call(db=db, phone_call=phone_call)

@app.get("/phone_calls/{call_id}", response_model=schemas.PhoneCall)
def read_phone_call(call_id: int, db: Session = Depends(get_db)):
    db_phone_call = crud.get_phone_call(db, call_id=call_id)
    if db_phone_call is None:
        raise HTTPException(status_code=404, detail="Phone call not found")
    return db_phone_call

@app.put("/phone_calls/{call_id}", response_model=schemas.PhoneCall)
def update_phone_call(call_id: int, phone_call: schemas.PhoneCallCreate, db: Session = Depends(get_db)):
    return crud.update_phone_call(db=db, call_id=call_id, phone_call=phone_call)

@app.delete("/phone_calls/{call_id}", response_model=schemas.PhoneCall)
def delete_phone_call(call_id: int, db: Session = Depends(get_db)):
    return crud.delete_phone_call(db=db, call_id=call_id)

