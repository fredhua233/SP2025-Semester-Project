from fastapi import FastAPI, Depends, HTTPException, BackgroundTasks
from app.schemas import schemas
# from app.crud import crud
from app.services import services
from app.database.database import add_moving_query, update_finished_call, get_moving_query


app = FastAPI()

# Dependency
# def get_db():
#     db = SessionLocal()
#     try:
#         yield db
#     finally:
#         db.close()

@app.post("/get_moving_companies/")
async def get_moving_companies(moving_query: schemas.MovingQuery, background_tasks: BackgroundTasks):
    moving_query_id = add_moving_query(moving_query=moving_query)
    background_tasks.add_task(services.get_moving_companies, moving_query, moving_query_id)

    return {"moving_query_id": moving_query_id}

@app.post("/call_moving_companies/")
async def call_moving_companies(moving_company_number: str, moving_company_id: int, moving_query_id: int):
    moving_query_data = get_moving_query(moving_query_id)
    if isinstance(moving_query_data, list) and len(moving_query_data) > 0:
        moving_query_data = moving_query_data[0]
    else:
        raise HTTPException(status_code=404, detail="Moving query not found")

    print(moving_query_data)

    items_details = moving_query_data["items_details"]
    availability = moving_query_data["availability"]
    location_from = moving_query_data["location_from"]
    location_to = moving_query_data["location_to"]

    return await services.create_phone_call(
        moving_query_id=moving_query_id,
        moving_company_id=moving_company_id,
        moving_company_number=moving_company_number,
        items=items_details,
        availability=availability,
        from_location=location_from,
        to_location=location_to
    )
@app.post("/vapi_webhook_report/")
def vapi_webhook_report(json_data: dict):
    print(json_data)
    if json_data.get("message", {}).get("type") == "end-of-call-report":
        # Extract the required fields
        vapi_id = json_data["message"]["call"]["id"]
        structured_data_price = json_data["message"]["analysis"]["structured_data"]["price"]
        summary = json_data["message"]["analysis"]["summary"]
        transcript = json_data["message"]["transcript"]
        duration_minutes = json_data["message"]["duration_minutes"]
        phone_number = json_data["message"]["call"]["customer"]["number"]
        print(f"VAPI ID: {vapi_id}")
        print(f"Structured Data Price: {structured_data_price}")
        print(f"Summary: {summary}")
        print(f"Transcript: {transcript}")
        print(f"Duration Minutes: {duration_minutes}")
        print(f"Phone Number: {phone_number}")
        
        update_finished_call(vapi_id, phone_number, structured_data_price, summary, transcript, duration_minutes)
        
    else:
        return None