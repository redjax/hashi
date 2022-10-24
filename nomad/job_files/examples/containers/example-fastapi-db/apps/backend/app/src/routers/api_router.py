from fastapi import APIRouter

from src.routers.example_db import potato_router

from core.config import settings, logging_settings
from core.logger import get_logger

log = get_logger(__name__)
log.setLevel(logging_settings.LOG_LEVEL)

prefix = settings.ROUTE_PREFIX
log.debug(f"Route prefix: {prefix}")

tags = ["default"]

router = APIRouter(
    prefix=prefix,
    responses={
        404: {"error": "Not found"},
        500: {"server_error": "Internal server error"},
    },
    tags=tags,
)


def create_routers():

    routers = [potato_router.router]

    for app_router in routers:
        router.include_router(app_router)

    return router


create_routers()
