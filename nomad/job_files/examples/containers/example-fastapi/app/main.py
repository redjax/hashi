from fastapi import FastAPI
import uvicorn

from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="FastAPI Nomad test",
    description="Testing FastAPI as a Nomad container",
    version="0.1",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
async def root():

    return {"message": "This is a FastAPI app running in Nomad!"}


if __name__ == "__main__":
    uvicorn.run("main:app", reload=True)
