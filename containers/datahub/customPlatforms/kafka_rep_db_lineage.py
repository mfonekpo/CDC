import os
from datahub.sdk import DataHubClient, DataFlow, DataJob
from utils.logging_conf import logger


DATAHUB_GMS_URL = os.getenv("DATAHUB_GMS_URL", "http://127.0.0.1:18080")

REPLICATION_POSTGRES_TABLE_URN = "urn:li:dataset:(urn:li:dataPlatform:postgres,replication-postgres.rep_db.rep_schema.cdc,PROD)"
KAFKA_TOPIC_URN = "urn:li:dataset:(urn:li:dataPlatform:kafka,aqi-kafka-local.cdc.cdc_schema.cdc,PROD)"

DATAJOB_ENV = os.getenv("DATAJOB_ENV", "PROD")

client = DataHubClient(server=DATAHUB_GMS_URL)
client.test_connection()



consumer_flow = DataFlow(
    platform="python",
    name="cdc_consumer_flow",
    env=DATAJOB_ENV,
        description=(
        "Custom Python CDC consumer pipeline that reads Debezium change events "
        "from Kafka and applies inserts, updates, and deletes to replication PostgreSQL."
    ),
)

client.entities.upsert(consumer_flow)

consumer_job = DataJob(
    flow=consumer_flow,
    name="postgres_consumer",
    display_name="Postgres CDC Consumer",
    description=(
        "Python consumer that reads CDC events from the Kafka topic, parses the "
        "Debezium event envelope, applies the corresponding PostgreSQL operation "
        "to the replication database, commits the transaction, and then commits "
        "the Kafka offset."
    ),
    inlets=[KAFKA_TOPIC_URN],
    outlets=[REPLICATION_POSTGRES_TABLE_URN],
    custom_properties={
        "runtime": "python",
        "consumer_role": "cdc_replication_writer",
        "input_event_format": "Debezium JSON envelope",
        "source_transport": "Kafka",
        "target_database_role": "replication-postgres",
        "offset_commit_policy": "commit Kafka offset after PostgreSQL transaction commit",
    },
)

client.entities.upsert(consumer_job)


client.lineage.add_lineage(
    upstream=KAFKA_TOPIC_URN,
    downstream=consumer_job.urn,
)

client.lineage.add_lineage(
    upstream=consumer_job.urn,
    downstream=REPLICATION_POSTGRES_TABLE_URN,
)

logger.info("Kafka topic -> Python CDC consumer -> replication Postgres lineage emitted successfully.")
logger.info(f"Consumer job URN: {consumer_job.urn}")