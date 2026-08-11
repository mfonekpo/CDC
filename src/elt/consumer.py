import json
from confluent_kafka import Consumer, KafkaException
import psycopg
from utils.postgres_conf import create_replication_connection


# ---------------------------------------------------------
# Configuration
# ---------------------------------------------------------

KAFKA_CONFIG = {
    'bootstrap.servers': 'localhost:29092',
    'group.id': 'replication-consumer',
    'auto.offset.reset': 'earliest',
    'enable.auto.commit': False
}

KAFKA_TOPIC = 'cdc.cdc_schema.cdc'


def connect_to_db():
    return create_replication_connection()


def subscribe() -> Consumer:
    consumer = Consumer(KAFKA_CONFIG)
    consumer.subscribe([KAFKA_TOPIC])
    return consumer

# ---------------------------------------------------------
# Debezium parsing
# ---------------------------------------------------------

def parse_event(msg) -> dict:

    raw_value = msg.value()

    if raw_value is None:
        raise ValueError("Message value is None")

    message = json.loads(
        raw_value.decode("utf-8")
    )

    event = message.get("payload")

    if event is None:
        raise ValueError("Debezium message has no payload")

    operation = event.get("op")

    if operation not in {"c", "u", "d", "r"}:
        raise ValueError(
            f"Unexpected operation type: {operation}"
        )

    return event


# ---------------------------------------------------------
# Event identity
# ---------------------------------------------------------

def build_event_id(msg):

    return (
        f"{msg.topic()}:"
        f"{msg.partition()}:"
        f"{msg.offset()}"
    )


def insert_data(payload, conn):
    ops = payload.get('op')


    if ops not in {"c", "r"}:
        raise NotImplementedError(
            f"Operation {ops} is not implemented yet"
        )

    row = payload.get("after")

    if row is None:
        raise ValueError(
            f"Operation {ops} has no 'after' payload"
        )

    with conn.cursor() as cursor:

        cursor.execute(
            """
            MERGE INTO rep_schema.cdc as target
            USING (
                VALUES (
                    %(id)s,
                    %(aqi)s,
                    %(date)s,
                    %(co_value)s,
                    %(ozone_value)s
                )
            ) AS source (
                id,
                aqi,
                date,
                co_value,
                ozone_value
            )
            ON target.id = source.id
            WHEN MATCHED THEN
                UPDATE SET
                    aqi = source.aqi,
                    date = source.date,
                    co_value = source.co_value,
                    ozone_value = source.ozone_value

            WHEN NOT MATCHED THEN
                INSERT (id, aqi, date, co_value, ozone_value) 
                VALUES (source.id, source.aqi, source.date, source.co_value, source.ozone_value)
            """,
            row,
        )


def main():
    consumer = subscribe()
    conn = connect_to_db()

    try:

        while True:
            msg = consumer.poll(1.0)
            if msg is None:
                continue

            if msg.error():
                print(f"Consumer error: {msg.error()}")
                continue

            event_id = build_event_id(msg)

            try:
                payload = parse_event(msg)
            except (json.JSONDecodeError, ValueError) as e:
                print(f"Invalid Debezium event {event_id}: {e}")
                continue
            try:
                insert_data(payload, conn)
                # PostgresSQL transaction succeeded
                conn.commit()

            except psycopg.Error as e:
                conn.rollback()
                print(f"PostgresQL error for {event_id}: {e}")
                continue

            try:
                # Only acknowledge Kafka after
                # PostgreSQL successfully committed.
                consumer.commit(
                    message=msg,
                    asynchronous=False,
                )

                print(
                    f"Successfully processed "
                    f"{event_id}"
                )

            except KafkaException as e:
                print(f"Kafka commit failed for event {event_id}: {e}")

    finally:
        conn.close()
        consumer.close()


if __name__ == "__main__":
    main()