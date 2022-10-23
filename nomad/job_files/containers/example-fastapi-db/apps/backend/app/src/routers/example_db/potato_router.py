from fastapi_crudrouter import SQLAlchemyCRUDRouter

from core.config import settings, logging_settings
from core.logger import get_logger

log = get_logger(__name__)
log.setLevel(logging_settings.LOG_LEVEL)

from src.dependencies import get_db, create_table_metadata

from src.models.example.example_models import Potato, PotatoCreate

tags = ["Example CRUD router"]

log.debug("Creating potato router")
router = SQLAlchemyCRUDRouter(
    schema=Potato, create_schema=PotatoCreate, db_model=Potato, db=get_db
)


@router.on_event("startup")
async def startup_event():
    log.info("Preparing potato database")
    create_table_metadata(Potato)
