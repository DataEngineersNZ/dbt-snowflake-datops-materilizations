-- Fails if any fanout task (root, branch_a, branch_b) does not exist
{% call statement('show_fanout_root', fetch_result=True) %}
    SHOW TASKS LIKE 'TEST_TASK_FANOUT_ROOT' IN SCHEMA {{ target.database }}.{{ target.schema }}
{% endcall %}
{% set fanout_root = load_result('show_fanout_root') %}

{% call statement('show_fanout_a', fetch_result=True) %}
    SHOW TASKS LIKE 'TEST_TASK_FANOUT_A' IN SCHEMA {{ target.database }}.{{ target.schema }}
{% endcall %}
{% set fanout_a = load_result('show_fanout_a') %}

{% call statement('show_fanout_b', fetch_result=True) %}
    SHOW TASKS LIKE 'TEST_TASK_FANOUT_B' IN SCHEMA {{ target.database }}.{{ target.schema }}
{% endcall %}
{% set fanout_b = load_result('show_fanout_b') %}

SELECT 'TEST_TASK_FANOUT_ROOT missing' AS failure_reason
WHERE {{ fanout_root.table | length }} = 0
UNION ALL
SELECT 'TEST_TASK_FANOUT_A missing' AS failure_reason
WHERE {{ fanout_a.table | length }} = 0
UNION ALL
SELECT 'TEST_TASK_FANOUT_B missing' AS failure_reason
WHERE {{ fanout_b.table | length }} = 0
