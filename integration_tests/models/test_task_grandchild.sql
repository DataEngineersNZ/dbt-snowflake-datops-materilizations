-- depends_on: {{ ref('test_task_child') }}
{{ config(
    materialized='task',
    meta={
        'is_serverless': true,
        'warehouse_name_or_size': 'xsmall',
        'task_after': 'test_task_child',
        'enabled_targets': []
    }
) }}

SELECT 1
