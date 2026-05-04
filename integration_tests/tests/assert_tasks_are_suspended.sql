-- Validates that all test tasks are suspended (since enabled_targets=[] for all test tasks)
-- This confirms the enable_tasks hook correctly respects enabled_targets

{% call statement('show_all_tasks', fetch_result=True) %}
    SHOW TASKS IN SCHEMA {{ target.database }}.{{ target.schema }}
{% endcall %}
{% set all_tasks = load_result('show_all_tasks') %}

{% set expected_tasks = [
    'TEST_TASK_ROOT',
    'TEST_TASK_CHILD',
    'TEST_TASK_GRANDCHILD',
    'TEST_TASK_SERVERLESS',
    'TEST_TASK_FANOUT_ROOT',
    'TEST_TASK_FANOUT_A',
    'TEST_TASK_FANOUT_B'
] %}

-- All tasks should be suspended since enabled_targets is empty
{% for row in all_tasks.table %}
    {% if row['name'] in expected_tasks and row['state'] != 'suspended' %}
SELECT '{{ row["name"] }} should be suspended but is {{ row["state"] }}' AS failure_reason
{{ 'UNION ALL' if not loop.last else '' }}
    {% endif %}
{% endfor %}

-- Fallback: if no tasks matched (all correctly suspended), return nothing
SELECT NULL AS failure_reason WHERE 1=0
