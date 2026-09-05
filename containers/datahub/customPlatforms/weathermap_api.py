import os
from platform import platform
from datahub.emitter.mcp import MetadataChangeProposalWrapper
from datahub.metadata.schema_classes import DataPlatformInfoClass, PlatformTypeClass
from datahub.metadata.urns import DataPlatformUrn
from datahub.sdk import DataHubClient, Dataset
from utils.logging_conf import logger

DATAHUB_GMS_URL = os.getenv("DATAHUB_GMS_URL", "http://127.0.0.1:18080")

AIRFLOW_LOAD_TASK_URN = "urn:li:dataJob:(urn:li:dataFlow:(airflow,producer_dag,prod),load)"
POSTGRES_LOAD_TASK_URN = "urn:li:dataset:(urn:li:dataPlatform:postgres,source-postgres.cdc_db.cdc_schema.cdc,PROD)"
API_DATASET_ENV = os.getenv("API_DATASET_ENV", "PROD")


client = DataHubClient(server=DATAHUB_GMS_URL)
client.test_connection()

# 1. Register the data platform (OpenWeatherMap) in DataHub
platform_urn = DataPlatformUrn("openweathermap").urn()
platform_info = DataPlatformInfoClass(
    name="OpenWeatherMap",
    displayName="openweathermap api source",
    type=PlatformTypeClass.OTHERS,
    datasetNameDelimiter="."
)

# 2. Emit the MetadataChangeProposal to register the platform
client._graph.emit(
    
    MetadataChangeProposalWrapper(
        entityType="dataPlatform",
        entityUrn=platform_urn,
        aspect=platform_info,
    )
)

# 3. Register the API response (current air quality data from OpenWeatherMap API) as a DataHub dataset
api_dataset = Dataset(
    platform="openweathermap",
    name="aqi_data_api.current_response",
    env=API_DATASET_ENV,
    display_name="Current Air Quality Data from OpenWeatherMap API",
    description=(
        "Current air pollution response payload from OpenWeatherMap. "
        "The Airflow task producer_dag.load calls fetch_air_quality(), "
        "extracts selected fields, validates them with the AirQualityReading "
        "Pydantic model, and loads them into source PostgreSQL."
    ),
    external_url="https://openweathermap.org/api/air-pollution",
    custom_properties={
        "provider": "OpenWeatherMap",
        "endpoint": "/data/2.5/air_pollution",
        "http_method": "GET",
        "called_by_dag": "producer_dag",
        "called_by_task": "load",
        "fetch_function": "fetch_air_quality",
        "load_function": "load_data",
        "target_table": "cdc_db.cdc_schema.cdc",
        "load_pattern": "hourly API pull",
        "idempotency_rule": "ON CONFLICT (date) DO NOTHING",
        "secret_env_var": "WEATHERAPI",
        "location_env_vars": "LAT,LONG",
    },
    schema=[
        ("main.aqi", "integer", "Air Quality Index from the API response."),
        ("dt", "integer", "Unix timestamp of the air quality reading."),
        ("components.co", "double", "Carbon monoxide value from the API response components object."),
        ("components.o3", "double", "Ozone value from the API response components object."),
    ],
)

client.entities.upsert(api_dataset)

# 4. Add Lineage edges.
client.lineage.add_lineage(
    upstream=api_dataset.urn,
    downstream=AIRFLOW_LOAD_TASK_URN,
)

client.lineage.add_lineage(
    upstream=AIRFLOW_LOAD_TASK_URN,
    downstream=POSTGRES_LOAD_TASK_URN,
)

logger.info("OpenWeatherMap API -> Airflow task -> Postgres table lineage emitted successfully.")
logger.info(f"API dataset URN: {api_dataset.urn}")
logger.info(f"Airflow task URN: {AIRFLOW_LOAD_TASK_URN}")
logger.info(f"Postgres table URN: {POSTGRES_LOAD_TASK_URN}")