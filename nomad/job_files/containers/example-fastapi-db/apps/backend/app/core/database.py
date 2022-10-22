from core.config import database_settings, logging_settings
from core.logger import get_logger

log = get_logger(__name__)
log.setLevel(logging_settings.LOG_LEVEL)


def get_db_uri():
    DB_URI = f"postgresql://{database_settings.DB_USER}:{database_settings.DB_PASSWORD}@{database_settings.DB_HOST}/{database_settings.DB_NAME}"

    return DB_URI
