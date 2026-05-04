{{ config(
    materialized='immutable_table',
    meta={
        'is_hybrid': true,
        'primary_keys': ['id']
    }
) }}

SELECT
    1 AS id,
    'hybrid_record' AS name
