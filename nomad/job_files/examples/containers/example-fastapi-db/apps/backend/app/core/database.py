from pathlib import Path

from sqlmodel import create_engine
from core.models.db_connection_models import SQLite, Postgres

from core.config import database_settings, logging_settings
from core.logger import get_logger

log = get_logger(__name__)
log.setLevel(logging_settings.LOG_LEVEL)


def get_engine():
    """Read DB_TYPE from env, create class model & engine for that DB."""

    log.info("Getting database engine")

    db_type = database_settings.DB_TYPE
    log.debug(f"Database type: {db_type}")

    if db_type != "undefined":
        if db_type == "sqlite":
            log.debug("Creating SQLite DB object for")
            db = SQLite()

            log.debug(f"SQLite connection URI: {db.db_uri}")

        elif db_type == "postgres":
            log.debug("Creating Postgres DB object for")
            db = Postgres()

            log.debug(f"Postgres connection URI: {db.db_uri}")
            log.debug(f"Postgres database: {db.db_name}")

        engine = create_engine(db.db_uri)

        return engine

    else:
        return None


log.debug("Creating engine")
engine = get_engine()
