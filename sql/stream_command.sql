CREATE STREAM IF NOT EXISTS aqi_data_stream
ON TABLE "cdc.cdc_schema.cdc";


CREATE OR REPLACE TASK refresh_aqi_data_task
WAREHOUSE = "cdc-warehouse"
WHEN SYSTEM$STREAM_HAS_DATA('aqi_data_stream')
AS
MERGE INTO aqi_data target
USING (
    SELECT
        payload:op::STRING AS operation,
        COALESCE(payload:after:id::INTEGER, payload:before:id::INTEGER) AS id,
        payload:after:aqi::INTEGER AS aqi,
        payload:after:date::INTEGER AS date_epoch,
        payload:after:co_value::FLOAT AS co_value,
        payload:after:ozone_value::FLOAT AS ozone_value
    FROM aqi_data_stream
    WHERE payload IS NOT NULL
      AND COALESCE(payload:after:id::INTEGER, payload:before:id::INTEGER) IS NOT NULL
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY COALESCE(payload:after:id::INTEGER, payload:before:id::INTEGER)
        ORDER BY payload:ts_ms::NUMBER DESC
    ) = 1
) source
ON target.id = source.id

WHEN MATCHED AND source.operation = 'd' THEN DELETE

WHEN MATCHED AND source.operation IN ('c', 'u', 'r') THEN UPDATE SET
    aqi = source.aqi,
    date_epoch = source.date_epoch,
    co_value = source.co_value,
    ozone_value = source.ozone_value

WHEN NOT MATCHED AND source.operation IN ('c', 'u', 'r') THEN INSERT (
    id,
    aqi,
    date_epoch,
    co_value,
    ozone_value
)
VALUES (
    source.id,
    source.aqi,
    source.date_epoch,
    source.co_value,
    source.ozone_value
);

select * from aqi_data
order by id;


-- Resume task
alter task refresh_aqi_data_task RESUME;


-- Sanity checks
SHOW TASKS LIKE 'REFRESH_AQI_DATA_TASK';

SELECT SYSTEM$STREAM_HAS_DATA('aqi_data_stream');

SELECT *
FROM aqi_data
ORDER BY date_epoch DESC;


SELECT *
FROM TABLE(INFORMATION_SCHEMA.TASK_HISTORY(
    TASK_NAME => 'REFRESH_AQI_DATA_TASK'
))
ORDER BY SCHEDULED_TIME DESC;