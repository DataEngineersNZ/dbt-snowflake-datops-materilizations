{{ config(
    materialized='alert',
    meta={
        'warehouse_size': target.warehouse,
        'schedule': '1440 MINUTE',
        'action': 'SELECT 1',
        'enabled_targets': []
    }
) }}

SELECT 1 FROM TABLE(GENERATOR(ROWCOUNT => 0))
