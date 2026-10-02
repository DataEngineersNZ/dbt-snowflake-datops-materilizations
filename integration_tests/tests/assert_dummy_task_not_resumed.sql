-- Proves enable_tasks' package scoping (scope_nodes_to_selection) excludes tasks owned by an
-- installed package other than the current/root project. dummy_task (defined in dbt_dummy_package)
-- has enabled_targets=[target.name], so it gets auto-resumed by its own creation materialization,
-- then explicitly suspended again by `suspend_dummy_task` (see .github/workflows). If enable_tasks
-- incorrectly swept it back into scope (the pre-fix behavior), it would be resumed again here.
{% call statement('show_dummy_task', fetch_result=True) %}
    SHOW TASKS LIKE 'DUMMY_TASK' IN SCHEMA {{ target.database }}.{{ target.schema }}
{% endcall %}
{% set dummy_tasks = load_result('show_dummy_task') %}

{% if dummy_tasks.table | length != 1 %}
SELECT 'Expected exactly one DUMMY_TASK row, found {{ dummy_tasks.table | length }}' AS failure_reason
{% elif dummy_tasks.table[0]['state'] != 'suspended' %}
SELECT 'DUMMY_TASK should remain suspended (excluded by package scoping) but is {{ dummy_tasks.table[0]["state"] }}' AS failure_reason
{% else %}
SELECT NULL AS failure_reason WHERE 1=0
{% endif %}
