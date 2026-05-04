{{ config(
    materialized='immutable_table',
    create_or_replace=true
) }}

SELECT 'core_style' AS config_style, 1 AS id
