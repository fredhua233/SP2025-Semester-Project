from sqlalchemy.orm import Session
from fastapi import APIRouter, HTTPException
import requests

from app.models import models
from app.schemas import schemas

# Function that takes a city and returns the moving companies in that city
async def get_moving_companies(city: str, db: Session):
    companies = db.query(models.MovingCompany).filter(models.MovingCompany.city == city).all()
    if not companies:
        raise HTTPException(status_code=404, detail="No moving companies found in the specified city")
    return companies

# Function that takes a moving company, an origin and destination city and returns true or false if the query has already been made


# Function that takes moving companies and makes a phone call to each of them
async def create_phone_call(customer_number, items, availability, from_location, to_location, phone_number_id):
    data = {
        'assistant': {
            "firstMessage": "Hi! I'm calling for a quote on my move, is this a good time?",
            "model": {
                "provider": "groq",
                "model": "llama-3.3-70b-versatile",
                "messages": [
                    {
                        "role": "system",
                        "content": f"""You are calling a moving company and get a quote for your move.
                        Your task is to share the following details about the move with the moving company:
                        1. Introduce yourself: 
                            “Hi, I'm calling for a moving quote.”
                        2. Share Move Details:
                            "I am moving from {from_location} to {to_location}."
                            "I'm looking to move {items}"
                            "I'm available on {availability} for the move."
                        3. Ask for the Quote: Directly request the quote and clarify what's included (e.g., labor, truck fees), make sure to ask the company how this quote is broken down and calculated.
                            Stay Focused: Politely keep the conversation on track if they go off-topic.
                        4. Wrap Up: 
                            Summarize: “Thanks for the quote! I'll share this with the customer, and they'll follow up if needed.”
                            Your only goal is to get the quote efficiently and professionally. Keep it short, friendly, and on-task."""
                    }
                ]
            },
            "voice": "jennifer-playht"
        },
        'phoneNumberId': phone_number_id,
        'customer': {
            'number': customer_number, # +14157698863
        },
    }
    headers = {
        'Authorization': 'Bearer YOUR_API_KEY',
        'Content-Type': 'application/json'
    }
    response = requests.post('https://api.vapi.ai/call/phone', headers=headers, json=data)

    if response.status_code == 201:
        print('Call created successfully')
        print(response.json())
    else:
        print('Failed to create call')
        print(response.text)
    return {"message": "List of phone calls"}

# Function to make calls using the moving query
async def make_calls(moving_query: schemas.MovingQueryCreate):
    moving_companies = await get_moving_companies(moving_query.location_from)

    for company in moving_companies:  
        await create_phone_call(
            customer_number=company.phone_number,
            items=moving_query.items,
            availability=moving_query.date,
            from_location=moving_query.location_from,
            to_location=moving_query.location_to,
            phone_number_id=company["phone_number"]
        )