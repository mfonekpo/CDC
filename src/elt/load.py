import psycopg
from .fetch import fetch_air_quality
from utils.logging_conf import logger
from utils.postgres_conf import create_connection


def load_data():
    """
    Load layer — only responsibility is inserting the validated reading into the database.
    Has zero knowledge of fetching or alerting.
    """
    try:
        aqi_value = fetch_air_quality()
        logger.info(f"Fetched air quality data: {aqi_value}")

        with create_connection() as conn:
            cur = conn.cursor()
            cur.execute(
                """
                INSERT INTO cdc_schema.cdc (aqi, date, co_value, ozone_value)
                VALUES (%(aqi)s, %(date)s, %(co_value)s, %(ozone_value)s)
                ON CONFLICT (date) DO NOTHING
                """,
                aqi_value
            )
            logger.info("Data inserted into the database successfully.")
    except psycopg.Error as e:
        logger.error(f"Database error occurred: {e}")
        raise

    except Exception as e:
        logger.error(f"An unexpected error occurred: {e}")
        raise