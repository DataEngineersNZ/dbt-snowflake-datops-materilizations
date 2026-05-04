{{ config(
    materialized='snowflake_materialized_view',
    tags=['enterprise_only'],
    meta={
        'secure': false
    }
) }}

SELECT
    1 AS id,
    'test' AS name
FROM TABLE(GENERATOR(ROWCOUNT => 1))
