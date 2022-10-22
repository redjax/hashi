from fastapi import FastAPI
import uvicorn

from fastapi.middleware.cors import CORSMiddleware

from core.config import settings, database_settings, logging_settings
from core.database import get_db_uri

from core.logger import get_logger

log = get_logger(__name__)
log.setLevel(logging_settings.LOG_LEVEL)

DB_URI = get_db_uri()

log.debug(f"DB URI: {DB_URI}")
log.debug(f"App Title: {settings.APP_TITLE}")


app = FastAPI(
    title=settings.APP_TITLE,
    description=settings.APP_DESCRIPTION,
    version=settings.APP_VERSION,
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

    # return {"message": "FastAPI server for FastAPI + Postgres"}
    return {"message": f"Test DB URI: {DB_URI}"}


if __name__ == "__main__":
    uvicorn.run("main:app", reload=True)
