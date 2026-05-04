{{ config(materialized='immutable_table') }}

SELECT
    1 AS id,
    'test_record' AS name,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS created_at
