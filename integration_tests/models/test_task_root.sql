{{ config(
    materialized='task',
    meta={
        'is_serverless': true,
        'warehouse_name_or_size': 'xsmall',
        'schedule': '60 MINUTE',
        'enabled_targets': []
    }
) }}

SELECT 1
