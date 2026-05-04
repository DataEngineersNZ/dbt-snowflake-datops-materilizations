{{ config(
    materialized='task',
    meta={
        'is_serverless': true,
        'warehouse_name_or_size': 'xsmall',
        'task_after': 'test_task_root',
        'enabled_targets': []
    }
) }}

SELECT 1
