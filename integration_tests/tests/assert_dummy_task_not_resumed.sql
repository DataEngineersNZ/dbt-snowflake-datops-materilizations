-- Proves enable_tasks' package scoping (scope_nodes_to_selection) excludes tasks owned by an
-- installed package other than the current/root project. dummy_task (defined in dbt_dummy_package)
-- has enabled_targets=[target.name], so it gets auto-resumed by its own creation materialization,
-- then explicitly suspended again by `suspend_dummy_task` (see .github/workflows). If enable_tasks
-- incorrectly swept it back into scope (the pre-fix behavior), it would be resumed again here.
{% call statement('show_dummy_task', fetch_result=True) %}
    SHOW TASKS LIKE 'DUMMY_TASK' IN SCHEMA {{ target.database }}.{{ target.schema }}
{% endcall %}
{% set dummy_tasks = load_result('show_dummy_task') %}

{% for row in dummy_tasks.table %}
    {% if row['state'] != 'suspended' %}
SELECT 'DUMMY_TASK should remain suspended (excluded by package scoping) but is {{ row["state"] }}' AS failure_reason
{{ 'UNION ALL' if not loop.last else '' }}
    {% endif %}
{% endfor %}

-- Fallback: if no rows matched (correctly excluded/suspended), return nothing
SELECT NULL AS failure_reason WHERE 1=0
