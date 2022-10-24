from sqlmodel import Session
from core.database import engine

from core.config import logging_settings
from core.logger import get_logger

log = get_logger(__name__)
log.setLevel(logging_settings.LOG_LEVEL)


def get_db():
    """Get connection to database."""

    db = Session(engine)

    try:
        log.info("Attempting to connect to database")
        yield db
    finally:
        log.info("Initial connection successful, closing connection.")
        db.close()


def create_table_metadata(base):
    """Create tables from base object passed to function. This can be a pydantic/sqlmodel model."""
    log.info(f"Creating table metadata for {base}")
    base.metadata.create_all(bind=engine)
