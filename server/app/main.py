from fastapi import FastAPI, Depends
import uvicorn
from .routers import moving_queries, moving_companies, phone_calls
from .dependencies import get_query, get_token_header

app = FastAPI(title="Moving Services API", version="1.0.0", description="API for managing moving services")

# Middleware setup (if any, such as CORS, Authentication, etc.)
# app.add_middleware(
#     SomeMiddleware,
#     some_argument='example'
# )

# Dependency injection (if globally applicable)
app.dependency_overrides[get_token_header] = get_query

# Register routers
app.include_router(
    moving_queries.router,
    prefix="/moving_queries",
    tags=["moving_queries"],
    dependencies=[Depends(get_token_header)],
    responses={404: {"description": "Not found"}},
)

app.include_router(
    moving_companies.router,
    prefix="/moving_companies",
    tags=["moving_companies"]
)

app.include_router(
    phone_calls.router,
    prefix="/phone_calls",
    tags=["phone_calls"]
)

# You might also have root or health check endpoints
@app.get("/", tags=["Root"])
async def root():
    return {"message": "Welcome to the Moving Services API!"}

@app.get("/start_instructions", tags=["Instructions"])
async def start_instructions():
    return {
        "instructions": "To start the app, run the following command: 'uvicorn app.main:app --reload'"
    }

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)