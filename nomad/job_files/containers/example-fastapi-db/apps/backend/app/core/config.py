from typing import Union
from pydantic import BaseSettings, Field, AnyHttpUrl, validator, Field


class SettingsBase(BaseSettings):
    pass


class Settings(BaseSettings):

    BACKEND_CORS_ORIGINS: list[Union[str, AnyHttpUrl]] = Field(
        default=["http://localhost:7001"], env="BACKEND_CORS_ORIGINS"
    )
    # Prefix for endpoints, i.e. example.com/api/v1/endpoint
    ROUTE_PREFIX: str = Field(default="/api/v1", env="ROUTE_PREFIX")
    APP_TITLE: str = Field(default="FastAPI - Boilerplate", env="APP_TITLE")
    APP_DESCRIPTION: str = Field(
        default="FastAPI, Docker, NGINX, & more", env="APP_DESCRIPTION"
    )
    APP_VERSION: str = Field(default="0.1", env="APP_VERSION")
    APP_HOST: str = Field(default="0.0.0.0", env="APP_HOST")
    APP_PORT: int = Field(default=7001, env="APP_PORT")


class LoggingSettings(SettingsBase):

    LOG_LEVEL: str = Field(default="INFO", env="LOG_LEVEL")
    LOG_FILE: str = Field(default="", env="LOG_FILE")


class DatabaseSettings(Settings):

    DB_TYPE: str = Field(default=None, env="DB_TYPE")
    DB_HOST: str = Field(default=None, env="DB_HOST")
    DB_PORT: int = Field(default=5432, env="DB_PORT")
    DB_USER: str = Field(default=None, env="DB_USER")
    DB_PASSWORD: str = Field(default=None, env="DB_PASSWORD")
    DB_NAME: str = Field(default=None, env="DB_NAME")
    # DB_URI: str = Field(default=None, env="DB_URI")

    class Config:
        validate_assignment = True

    @validator("DB_PORT", pre=True)
    def allow_none(cls, val):
        if val is None:
            return None
        else:
            return val


settings = Settings()
logging_settings = LoggingSettings()
database_settings = DatabaseSettings()
