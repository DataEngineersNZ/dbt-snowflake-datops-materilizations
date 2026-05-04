{{ config(
    materialized='task',
    meta={
        'is_serverless': true,
        'warehouse_name_or_size': 'medium',
        'schedule': '1440 MINUTE',
        'timeout': 3600000,
        'suspend_after_number_of_failures': 3,
        'enabled_targets': []
    }
) }}

SELECT CURRENT_TIMESTAMP()
