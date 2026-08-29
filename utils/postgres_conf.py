import psycopg
from utils.logging_conf import logger

def create_connection():
    """
    Create a connection to the PostgreSQL database.

    Returns:
        psycopg.Connection: A connection object to the PostgreSQL database.
    """
    try:
        conn = psycopg.connect(
        host="cdc-postgres", #uses the cdc container service name
        port=5432,
        dbname="cdc_db",
        user="cdc",
        password="root"
        )
        logger.info("Connected to the PostgreSQL database")
        return conn
    except psycopg.Error as e:
        logger.error(f"Error connecting to the PostgreSQL database: {e}")
        raise


def create_replication_connection():
    """
    Create a connection to the PostgreSQL database for replication.

    Returns:
        psycopg.Connection: A connection object to the PostgreSQL database for replication.
    """
    try:
        conn = psycopg.connect(
        host="replication-postgres", #uses the replication container service name
        port=5432,
        dbname="rep_db",
        user="postgres",
        password="root"
        )
        return conn
    except psycopg.Error as e:
        logger.error(f"Error connecting to the PostgreSQL database for replication: {e}")
        raise