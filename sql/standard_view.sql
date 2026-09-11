CREATE OR REPLACE VIEW cdc_db.aqi_schema.stg_air_quality_cdc_events AS
SELECT
    RECORD_METADATA:"CreateTime"::NUMBER AS kafka_create_time,
    RECORD_METADATA:"SnowflakeConnectorPushTime"::NUMBER AS snowflake_connector_push_time,

    PAYLOAD:op::STRING AS operation,

    PAYLOAD:before:id::INTEGER AS before_id,
    PAYLOAD:before:aqi::INTEGER AS before_aqi,
    PAYLOAD:before:date::INTEGER AS before_date,
    PAYLOAD:before:co_value::FLOAT AS before_co_value,
    PAYLOAD:before:ozone_value::FLOAT AS before_ozone_value,

    PAYLOAD:after:id::INTEGER AS id,
    PAYLOAD:after:aqi::INTEGER AS aqi,
    PAYLOAD:after:date::INTEGER AS date_epoch,
    TO_TIMESTAMP_NTZ(PAYLOAD:after:date::INTEGER) AS reading_timestamp,
    PAYLOAD:after:co_value::FLOAT AS co_value,
    PAYLOAD:after:ozone_value::FLOAT AS ozone_value,

    PAYLOAD:source:db::STRING AS source_database,
    PAYLOAD:source:schema::STRING AS source_schema,
    PAYLOAD:source:table::STRING AS source_table,
    PAYLOAD:source:lsn::NUMBER AS source_lsn,
    PAYLOAD:ts_ms::NUMBER AS event_timestamp_ms,

    PAYLOAD AS raw_payload
FROM "cdc.cdc_schema.cdc";

select * from stg_air_quality_cdc_events;




CREATE OR REPLACE TABLE aqi_schema.AIR_QUALITY_READINGS (
    id INTEGER,
    aqi INTEGER,
    date_epoch INTEGER,
    reading_timestamp TIMESTAMP_NTZ,
    co_value FLOAT,
    ozone_value FLOAT,
    last_cdc_operation STRING,
    last_updated_at TIMESTAMP_NTZ
);





MERGE INTO aqi_schema.AIR_QUALITY_READINGS target
USING cdc_db.aqi_schema.stg_air_quality_cdc_events source
ON target.id = source.id

WHEN MATCHED AND source.operation = 'd' THEN DELETE

WHEN MATCHED AND source.operation IN ('u', 'c', 'r') THEN UPDATE SET
    aqi = source.aqi,
    date_epoch = source.date_epoch,
    reading_timestamp = source.reading_timestamp,
    co_value = source.co_value,
    ozone_value = source.ozone_value,
    last_cdc_operation = source.operation,
    last_updated_at = CURRENT_TIMESTAMP()

WHEN NOT MATCHED AND source.operation IN ('c', 'r', 'u') THEN INSERT (
    id,
    aqi,
    date_epoch,
    reading_timestamp,
    co_value,
    ozone_value,
    last_cdc_operation,
    last_updated_at
)
VALUES (
    source.id,
    source.aqi,
    source.date_epoch,
    source.reading_timestamp,
    source.co_value,
    source.ozone_value,
    source.operation,
    CURRENT_TIMESTAMP()
);


select * from aqi_schema.air_quality_readings;