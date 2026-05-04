-- depends_on: {{ ref('test_task_fanout_root') }}
{{ config(
    materialized='task',
    meta={
        'is_serverless': true,
        'warehouse_name_or_size': 'xsmall',
        'task_after': 'test_task_fanout_root',
        'enabled_targets': []
    }
) }}

SELECT 'branch_b'
