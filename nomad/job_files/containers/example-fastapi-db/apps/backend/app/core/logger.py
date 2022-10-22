from pydantic import BaseSettings
from typing import Any
import sys
import logging
from logging.handlers import RotatingFileHandler


datefmt = "%y-%m-%d %H:%M:%S"


class BaseLogger(BaseSettings):

    NAME: str = __name__
    LOG_LEVEL: str = "INFO"
    FORMATTER: Any = logging.Formatter(
        fmt="[%(asctime)s]:[%(levelname)s]:[%(name)s]:[Line-%(lineno)d]> %(message)s",
        datefmt=datefmt,
    )


class FileLogger(BaseLogger):

    NAME: str = __name__
    LOG_LEVEL: str = "DEBUG"
    LOG_FILE: str = "api.log"
    FORMATTER: Any = logging.Formatter(
        fmt="[%(asctime)s]:[%(levelname)s]:[%(name)s]:Proc:%(process)d]:[Line-%(lineno)d]> %(message)s",
        datefmt=datefmt,
    )
    ROTATE_WHEN: str = "midnight"
    MAX_BYTES: int = 100 * 1024
    BACKUP_COUNT: int = 3


class ConsoleLogger(BaseLogger):

    pass


class UvicornLogger(BaseLogger):

    FORMATTER: Any = logging.Formatter(
        fmt="[%(asctime)s]:[%(levelname)s]:[%(name)s]:[%(process)d]:[%(lineno)d]> %(message)s",
        datefmt=datefmt,
    )
    NAME: str = "uvicorn.access"
    LOG_FILE: str = "uvicorn_access.log"


def get_console_handler():
    console_config = ConsoleLogger()

    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setFormatter(console_config.FORMATTER)

    return console_handler


def get_file_handler():
    file_config = FileLogger(LOG_FILE="api.log")

    ## If using TimedRotatingFileHandler, replace maxBytes & backupCount with: when=file_config.ROTATE_WHEN,
    file_handler = RotatingFileHandler(
        file_config.LOG_FILE,
        maxBytes=file_config.MAX_BYTES,
        backupCount=file_config.BACKUP_COUNT,
    )
    file_handler.setFormatter(file_config.FORMATTER)

    return file_handler


def get_uvicorn_console_handler():
    uvicorn_config = UvicornLogger(LOG_FILE="uvicorn.access.log")
    # print(f"uvicorn_config: {uvicorn_config}")

    # uvicorn_handler = RotatingFileHandler(uvicorn_config.LOG_FILE, mode="a", maxBytes = 100*1024, backupCount = 3)
    uvicorn_console_handler = logging.StreamHandler()
    uvicorn_console_handler.setFormatter(uvicorn_config.FORMATTER)

    return uvicorn_console_handler


def get_uvicorn_file_handler():
    uvicorn_config = UvicornLogger(LOG_FILE="uvicorn.access.log")
    uvicorn_file_handler = RotatingFileHandler(
        uvicorn_config.LOG_FILE, mode="a", maxBytes=100 * 1024, backupCount=3
    )
    uvicorn_file_handler.setFormatter(uvicorn_config.FORMATTER)

    return uvicorn_file_handler


def get_logger(logger_name, level="INFO"):
    logger = logging.getLogger(logger_name)
    logger.setLevel(level.upper())
    logger.addHandler(get_console_handler())
    logger.addHandler(get_file_handler())

    ## Propagate error up to parent
    logger.propagate = False

    return logger


def get_uvicorn_logger(logger_name="uvicorn.access", level="DEBUG"):

    logger = logging.getLogger(logger_name)
    logger.setLevel(level.upper())
    # logger.addHandler(get_uvicorn_console_handler())
    logger.addHandler(get_uvicorn_file_handler())

    logger.propagate = False

    return logger
