{{ config(materialized='immutable_table', meta={'create_or_replace': true}) }}

SELECT
    1 AS id,
    'replaced_record' AS name,
    CURRENT_TIMESTAMP()::TIMESTAMP_NTZ AS created_at
