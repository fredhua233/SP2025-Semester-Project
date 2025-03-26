from sqlalchemy.orm import Session
from fastapi import APIRouter, HTTPException
import httpx
import requests
from app.utils import get_lat_long
# from app.models import models
from app.schemas import schemas
from app.database.database import get_or_create_moving_company, create_inquiry, update_vapi_id
import os
from dotenv import load_dotenv


load_dotenv()


# Function that takes a city and returns the moving companies in that city
async def get_moving_companies(moving_query: schemas.MovingQuery, moving_query_id):
    print(moving_query_id)
    api_key = os.getenv("MAPS_API_KEY")
    query = "moving company"
    location = await get_lat_long(moving_query.location_from, api_key)
    if location is None:
        raise HTTPException(status_code=400, detail="Invalid location provided")
    radius = 80467  # 50 miles in meters
    url = f"https://maps.googleapis.com/maps/api/place/textsearch/json?query={query}&location={location}&radius={radius}&key={api_key}"

    response = requests.get(url)
    if response.status_code != 200:
        raise HTTPException(status_code=response.status_code, detail="Error fetching data from Google Places API")

    results = response.json().get("results", [])
    nearby_companies = []

    for result in results[:5]:
        place_id = result["place_id"]
        details_url = f"https://maps.googleapis.com/maps/api/place/details/json?place_id={place_id}&key={api_key}"
        details_response = requests.get(details_url)
        if details_response.status_code != 200:
            continue
        details_result = details_response.json().get("result", {})
        phone_number = "+1" + details_result.get("formatted_phone_number").translate({ord(c): None for c in "()- "})
        # https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=photo_reference&key=api_key
        # ^^^ use as a get request to get the image of the moving company

        company = {
            "name": result["name"],
            "address": result["formatted_address"],
            "rating": result.get("rating"),
            "user_ratings_total": result.get("user_ratings_total"),
            "latitude": result["geometry"]["location"]["lat"],
            "longitude": result["geometry"]["location"]["lng"],
            "phone_number": phone_number,
        }
        company_id = get_or_create_moving_company(company)
        create_inquiry(moving_query_id, phone_number, company_id)

        nearby_companies.append(company)

    hardcoded_company = {
    "name": "Fred Hua",
    "address": "123 Example St, Example City, EX 12345",
    "rating": 4.5,
    "user_ratings_total": 100,
    "latitude": 40.7128,  # Example latitude
    "longitude": -74.0060,  # Example longitude
    "phone_number": "+14106885756",
    }
    company_id = get_or_create_moving_company(hardcoded_company)
    create_inquiry(moving_query_id, hardcoded_company["phone_number"], company_id)



# Function that takes moving companies and makes a phone call to each of them
async def create_phone_call(moving_query_id, moving_company_id, moving_company_number, items, availability, from_location, to_location):
    moving_company_number = f"+{moving_company_number.lstrip('+').replace(' ', '')}"
    vapi_api = os.getenv("VAPI_API_KEY")
    phone_id = os.getenv("VAPI_PHONE_ID")
    
    data = {
        # 'assistant': {
        #     "firstMessage": "Hi! I'm calling for a quote on my move, is this a good time?",
        #     "model": {
        #         "provider": "groq",
        #         "model": "llama-3.3-70b-versatile",
        #         "messages": [
        #             {
        #                 "role": "system",
        #                 "content": f"""You are calling a moving company and get a quote for your move.
        #                 Your task is to share the following details about the move with the moving company:
        #                 1. Introduce yourself: 
        #                     “Hi, I'm calling for a moving quote.”
        #                 2. Share Move Details:
        #                     "I am moving from {from_location} to {to_location}."
        #                     "I'm looking to move {items}"
        #                     "I'm available on {availability} for the move."
        #                 3. Ask for the Quote: Directly request the quote and clarify what's included (e.g., labor, truck fees), make sure to ask the company how this quote is broken down and calculated.
        #                     Stay Focused: Politely keep the conversation on track if they go off-topic.
        #                 4. Wrap Up: 
        #                     Summarize: “Thanks for the quote! I'll share this with the customer, and they'll follow up if needed.”
        #                     Your only goal is to get the quote efficiently and professionally. Keep it short, friendly, and on-task."""
        #             }
        #         ]
        #     },
        #     "voice": "jennifer-playht"
        # },
        # 'phoneNumberId': phone_id,
        # 'customer': {
        #     'number': moving_company_number, # +14157698863
        # },
        "assistantId": "829127fc-0226-4766-9160-79c7db241fa2",
        "assistantOverrides": {
            "variableValues": {
                "from_location": from_location,
                "to_location": to_location,
                "items": items,
                "availability": availability
            }
        },
        "customer": {
            "number": moving_company_number
        },
        "phoneNumberId": phone_id
    }
    headers = {
        'Authorization': f'Bearer {vapi_api}',
        'Content-Type': 'application/json'
    }
    
    response = requests.post('https://api.vapi.ai/call/phone', headers=headers, json=data)

    if response.status_code == 201:
        print('Call created successfully')
        print(response.json().get("id"))
        update_vapi_id(moving_query_id, moving_company_number, response.json().get("id"))
        
    else:
        print('Failed to create call')
        print(response.text)
    return {"message": "List of phone calls"}

# Function to make calls using the moving query
async def make_calls(moving_query: schemas.MovingQueryCreate, moving_companies: list):

    for company in moving_companies:
        create_phone_call(
            customer_number=company.phone_number,
            items=moving_query.items,
            availability=moving_query.date,
            from_location=moving_query.location_from,
            to_location=moving_query.location_to,
            phone_number_id=company["phone_number"]
        )

#returns price
async def process_phone_call(transcript : str):
    #parse transcript to get price

    prompt = "You are given the following transcript of a phone call with a moving company. The customer is asking for a quote for their move. The transcript is as follows: " + transcript + " Please provide the price quoted by the moving company and only the price in the form of a float."
    url = "https://api.openai.com/v1/engines/davinci/completions"
    headers = {
        "Authorization": f"Bearer {os.getenv('OPENAI_API_KEY')}",
    }
    data = {
        "model": "text-davinci-003",
        "prompt": prompt,
        "max_tokens": 50
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=data, headers=headers)
    print(response.json())
    if response.status_code != 200:
        raise HTTPException(status_code=400, detail="Error processing your request")

    return response



    