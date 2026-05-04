{{ config(
    materialized='immutable_table',
    meta={
        'create_or_replace': true
    }
) }}

SELECT 'fusion_style' AS config_style, 1 AS id
