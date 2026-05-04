-- Fails if the child task does not exist
{% call statement('show_tasks', fetch_result=True) %}
    SHOW TASKS LIKE 'TEST_TASK_CHILD' IN SCHEMA {{ target.database }}.{{ target.schema }}
{% endcall %}
{% set result = load_result('show_tasks') %}

SELECT 1
WHERE {{ result.table | length }} = 0
