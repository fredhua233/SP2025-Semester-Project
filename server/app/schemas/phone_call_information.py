from pydantic import BaseModel

class PhoneCallInformation(BaseModel):
    transcript: str
    time_of_call: str
    call_completed: bool
