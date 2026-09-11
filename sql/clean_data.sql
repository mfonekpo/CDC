CREATE OR REPLACE TABLE aqi_data (
    id INTEGER,
    aqi INTEGER,
    date_epoch INTEGER,
    co_value FLOAT,
    ozone_value FLOAT
);


-- creating clean data
MERGE INTO aqi_data target
USING (
    SELECT
        payload:op::STRING AS operation,
        COALESCE(payload:after:id::INTEGER, payload:before:id::INTEGER) AS id,
        payload:after:aqi::INTEGER AS aqi,
        payload:after:date::INTEGER AS date_epoch,
        payload:after:co_value::FLOAT AS co_value,
        payload:after:ozone_value::FLOAT AS ozone_value
    FROM "cdc.cdc_schema.cdc"
    WHERE payload IS NOT NULL
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