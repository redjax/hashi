"""
The classes in this file are pydantic models for building
database connection objects. I will most likely eventually
remove much of the database configuration in config.py,
and load database configurations dynamically from these
class files.
"""

from pydantic import BaseModel, Field
from typing import Dict

from core.config import database_settings, logging_settings

from core.logger import get_logger

log = get_logger(__name__)
log.setLevel(logging_settings.LOG_LEVEL)


class DatabaseBase(BaseModel):

    db_uri: str = None


class SQLiteBase(DatabaseBase):

    connect_args: Dict = {"check_same_thread": False}
    db_uri: str = f"sqlite:///{database_settings.DB_URI}"


class SQLite(SQLiteBase):
    pass


class PostgresBase(DatabaseBase):

    db_host: str = database_settings.DB_HOST
    db_name: str = database_settings.DB_NAME
    db_user: str = database_settings.DB_USER
    db_port: int = database_settings.DB_PORT
    db_password: str = database_settings.DB_PASSWORD
    db_uri: str = f"postgresql://{db_user}:{db_password}@{db_host}/{db_name}"


class Postgres(PostgresBase):
    pass
