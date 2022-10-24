from sqlmodel import SQLModel, Field


class PotatoCreate(SQLModel):

    thickness: float
    mass: float
    color: str
    type: str


class Potato(PotatoCreate, table=True):

    id: int = Field(primary_key=True)
