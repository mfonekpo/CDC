from datetime import datetime
from pydantic import BaseModel, field_validator, Field, ConfigDict

class AirqualityFetchError(Exception):
    """
    Raised when any part of the air quality pipeline fails.
    Defined here so all layers can import it without circular imports.
    """
    pass


class AirQualityReading(BaseModel):
    """
    Validation layer — only responsibility is validating the shape
    and business rules of a single air quality reading.
    Has zero knowledge of HTTP, storage, or alerting.
    """
    aqi: int
    date: int
    co_value: float
    ozone_value: float

    @field_validator("aqi")
    @classmethod
    def aqi_must_be_in_range(cls, v):
        if not 1 <= v <= 5:
            raise ValueError(f"AQI value {v} is outside expected range 1-5")
        return v


class AirQualityTransformedReading(BaseModel):
    """
    Validation layer — only responsibility is validating the shape
    and business rules of a single transformed air quality reading.
    Has zero knowledge of HTTP, storage, or alerting.
    """
    aqi: int
    date_epoch: int
    date_utc: datetime
    co_value: float
    ozone_value: float

    @field_validator("aqi")
    @classmethod
    def aqi_must_be_in_range(cls, v):
        if not 1 <= v <= 5:
            raise ValueError(f"AQI value {v} is outside expected range 1-5")
        return v
    

class AwsEventModel(BaseModel):
    model_config = ConfigDict(extra="ignore", populate_by_name=True)


class SqsSensorMessage(AwsEventModel):
    message_id: str = Field(alias="MessageId")
    receipt_handle: str = Field(alias="ReceiptHandle")
    body: str = Field(alias="Body")


class S3Bucket(AwsEventModel):
    name: str


class S3Object(AwsEventModel):
    key: str
    e_tag: str | None = Field(default=None, alias="eTag")
    version_id: str | None = Field(default=None, alias="versionId")


class S3Entity(AwsEventModel):
    bucket: S3Bucket
    s3_object: S3Object = Field(alias="object")


class S3EventRecord(AwsEventModel):
    event_name: str = Field(alias="eventName")
    s3: S3Entity


class S3EventBody(AwsEventModel):
    records: list[S3EventRecord] = Field(alias="Records")

    @field_validator("records")
    @classmethod
    def records_must_not_be_empty(cls, value):
        if not value:
            raise ValueError("S3 event body must contain at least one record")
        return value