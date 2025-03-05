from supabase import create_client, Client
from app.schemas.schemas import MovingQuery, MovingInquiry, MovingCompany
import os
from dotenv import load_dotenv

load_dotenv()
# Initialize Supabase client
url: str = os.getenv("SUPABASE_URL")
key: str = os.getenv("SUPABASE_KEY")
supabase: Client = create_client(url, key)

def add_moving_query(moving_query: MovingQuery):
    # Convert the MovingQuery instance to a dictionary
    moving_query_data = moving_query.dict()
    
    # Convert datetime to string
    moving_query_data['created_at'] = moving_query_data['created_at'].isoformat()

    # Insert the data into the Supabase table
    response = supabase.table("moving_query").insert(moving_query_data).execute()
    print(response)
    if response.data:
        inserted_row = response.data[0]  # Get the first (and only) inserted row
        return inserted_row.get('id')
    else:
        print("Error inserting data:", response.error)
        raise HTTPException(status_code=500, detail="Error inserting data")


def add_moving_inquiry(moving_inquiry: MovingInquiry):
    # Convert the MovingInquiry instance to a dictionary
    moving_inquiry_data = moving_inquiry.dict()

    # Insert the data into the Supabase table
    response = supabase.table("moving_inquiry").insert(moving_inquiry_data).execute()

    if response.status_code != 201:
        print("Error inserting data:", response.error)
    else:
        print("Data inserted successfully:", response.data)

def add_moving_company(moving_company: MovingCompany):
    # Convert the MovingInquiry instance to a dictionary
    moving_company_data = moving_company.dict()

    # Insert the data into the Supabase table
    response = supabase.table("moving_company").insert(moving_company_data).execute()

    if response.data:
        print("Data inserted successfully:", response.data) 
    else:
        print("Error inserting data:", response.error)

def get_or_create_moving_company(company: dict) -> int:
    phone_number = company["phone_number"]

    # Check if the company exists in the moving_company table
    existing_company_response = supabase.table("moving_company").select("id").eq("phone_number", phone_number).execute()
    if existing_company_response.data:
        company_id = existing_company_response.data[0]["id"]
    else:
        # Insert the new company into the moving_company table
        insert_response = supabase.table("moving_company").insert(company).execute()
        if not insert_response.data:
            raise HTTPException(status_code=500, detail="Error inserting new moving company")
        company_id = insert_response.data[0]["id"]

    return company_id

def create_inquiry(moving_query_id: int, phone_number: str, company_id: int):
    inquiry_data = {
        "moving_query_id": moving_query_id,
        "phone_number": phone_number,
        "moving_company_id": company_id,
        "price": -1,
        "phone_call_transcript": "",
        "in_progress": False
    }

    response = supabase.table("moving_inquiry").insert(inquiry_data).execute()
    if not response.data:
        print("Error inserting data:", response.error)
    else:
        print("Data inserted successfully:", response.data)

def update_vapi_id(moving_query_id: str, phone_number: str, id: str):
    # Update the "id" field of the moving_inquiry table based on moving_query_id and phone_number
    response = supabase.table("moving_inquiry").update({"vapi_call_id": id}).eq("moving_query_id", moving_query_id).eq("phone_number", phone_number).execute()
    # response = supabase.table("moving_inquiry").update({"vapi_call_id": id}).eq("moving_query_id", moving_query_id).execute()

    if not response.data:
        print("Error updating inquiry id:", response.error)
    else:
        print("Inquiry id updated successfully:", response.data)

def update_finished_call(vapi_id, phone_number, structured_data_price, summary, transcript, duration_minutes):
    # Update the moving_inquiry table with the provided data based on vapi_id
    response = supabase.table("moving_inquiry").update({
        "price": structured_data_price,
        "phone_call_transcript": transcript,
        "summary": summary,
        "call_duration": duration_minutes
    }).eq("vapi_call_id", vapi_id).eq("phone_number", phone_number).execute()

    if not response.data:
        print("Error updating finished call:", response.error)
    else:
        print("Finished call updated successfully:", response.data)

def get_moving_query(moving_query_id: int):
    response = supabase.table("moving_query").select(
        "location_from", 
        "location_to", 
        "created_at", 
        "items", 
        "items_details", 
        "availability", 
        "user_id"
    ).eq("id", moving_query_id).execute()
    return response.data