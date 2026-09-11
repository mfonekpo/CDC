import os
from datahub.sdk import DataHubClient
from utils.logging_conf import logger

DATAHUB_GMS_URL = os.getenv("DATAHUB_GMS_URL", "http://127.0.0.1:18080")
POSTGRES_SOURCE_TABLE_URN = "urn:li:dataset:(urn:li:dataPlatform:postgres,source-postgres.cdc_db.cdc_schema.cdc,PROD)"
KAFKA_TOPIC_URN = "urn:li:dataset:(urn:li:dataPlatform:kafka,aqi-kafka-local.cdc.cdc_schema.cdc,PROD)"

client = DataHubClient(server=DATAHUB_GMS_URL)
client.test_connection()

client.lineage.add_lineage(
    upstream=POSTGRES_SOURCE_TABLE_URN,
    downstream=KAFKA_TOPIC_URN,
    transformation_text=(
        "Debezium captures changes from the source PostgreSQL table using "
        "logical replication/WAL and publishes change events to this Kafka topic."
    ),
)


logger.info("Source Postgres table -> Kafka topic lineage emitted successfully.")