import requests

async def get_lat_long(address, api_key):
    # Construct the URL for the Google Maps Geocoding API
    url = f"https://maps.googleapis.com/maps/api/geocode/json?address={address}&key={api_key}"
    
    # Make a request to the API
    response = requests.get(url)
    
    # Check if the request was successful
    if response.status_code == 200:
        # Parse the JSON response
        data = response.json()
        
        # Check if the response contains results
        if data['results']:
            # Extract latitude and longitude
            location = data['results'][0]['geometry']['location']
            return f"{location['lat']},{location['lng']}"
        else:
            return None
    else:
        # Handle errors
        print(f"Error: {response.status_code}")
        return None, None
