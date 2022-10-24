from fastapi import FastAPI
import uvicorn

from fastapi.middleware.cors import CORSMiddleware

from core.config import settings, logging_settings
from core.database import engine
from core.logger import get_logger

log = get_logger(__name__)
log.setLevel(logging_settings.LOG_LEVEL)

from src.dependencies import create_table_metadata

from src.routers import api_router


log.debug(f"DB engine: {engine}")
log.debug(f"App Title: {settings.APP_TITLE}")


def create_app() -> FastAPI:

    app = FastAPI(
        title=settings.APP_TITLE,
        description=settings.APP_DESCRIPTION,
        version=settings.APP_VERSION,
    )

    log.debug(f"App Title: {app.title}")
    log.debug(f"App Description: {app.description}")
    log.debug(f"App Version: {app.version}")

    app.include_router(api_router.router)

    return app


log.info("Creating FastAPI app")
app = create_app()

if settings.BACKEND_CORS_ORIGINS:
    log.info("Adding app middleware")
    log.debug(f"Origins: {[str(origin) for origin in settings.BACKEND_CORS_ORIGINS]}")

    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )


@app.on_event("startup")
async def startup_event():
    log.info("Starting app")


@app.get("/")
async def root():

    return {"message": "FastAPI server for FastAPI + Postgres"}


if __name__ == "__main__":
    uvicorn.run("main:app", port=settings.APP_PORT, host=settings.APP_HOST, reload=True)
