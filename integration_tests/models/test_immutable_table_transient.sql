{{ config(materialized='immutable_table', meta={'transient': true}) }}

SELECT
    1 AS id,
    'transient_record' AS name,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS created_at
