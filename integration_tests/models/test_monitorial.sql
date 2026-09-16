{{ config(
    materialized='monitorial',
    meta={
        'object_type': 'alert',
        'is_serverless': false,
        'warehouse_name_or_size': target.warehouse,
        'schedule': '1440 MINUTE',
        'delivery_type': 'api',
        'enabled_targets': []
    }
) }}

SELECT 1 FROM TABLE(GENERATOR(ROWCOUNT => 0))
