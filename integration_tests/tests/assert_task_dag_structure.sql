-- Validates the 3-level task DAG has correct predecessor chains:
--   test_task_root (schedule) -> test_task_child (after root) -> test_task_grandchild (after child)
-- Also validates the fan-out DAG:
--   test_task_fanout_root (schedule) -> test_task_fanout_a (after fanout_root)
--                                    -> test_task_fanout_b (after fanout_root)
-- Also validates standalone root:
--   test_task_serverless (schedule, no children)

{% call statement('show_all_tasks', fetch_result=True) %}
    SHOW TASKS IN SCHEMA {{ target.database }}.{{ target.schema }}
{% endcall %}
{% set all_tasks = load_result('show_all_tasks') %}

-- Build a lookup of task name -> predecessors
{% set task_info = {} %}
{% for row in all_tasks.table %}
    {% do task_info.update({row['name']: row['predecessors']}) %}
{% endfor %}

-- Validate 3-level DAG
SELECT 'test_task_root should have no predecessors, got: ' || '{{ task_info.get("TEST_TASK_ROOT", "MISSING") }}' AS failure_reason
WHERE '{{ task_info.get("TEST_TASK_ROOT", "MISSING") }}' NOT IN ('[]', 'MISSING')
  AND '{{ task_info.get("TEST_TASK_ROOT", "MISSING") }}' != ''

UNION ALL
SELECT 'test_task_child should have test_task_root as predecessor' AS failure_reason
WHERE '{{ task_info.get("TEST_TASK_CHILD", "MISSING") }}' NOT LIKE '%TEST_TASK_ROOT%'
  AND '{{ task_info.get("TEST_TASK_CHILD", "MISSING") }}' != 'MISSING'

UNION ALL
SELECT 'test_task_grandchild should have test_task_child as predecessor' AS failure_reason
WHERE '{{ task_info.get("TEST_TASK_GRANDCHILD", "MISSING") }}' NOT LIKE '%TEST_TASK_CHILD%'
  AND '{{ task_info.get("TEST_TASK_GRANDCHILD", "MISSING") }}' != 'MISSING'

-- Validate fan-out DAG
UNION ALL
SELECT 'test_task_fanout_root should have no predecessors' AS failure_reason
WHERE '{{ task_info.get("TEST_TASK_FANOUT_ROOT", "MISSING") }}' NOT IN ('[]', 'MISSING')
  AND '{{ task_info.get("TEST_TASK_FANOUT_ROOT", "MISSING") }}' != ''

UNION ALL
SELECT 'test_task_fanout_a should have test_task_fanout_root as predecessor' AS failure_reason
WHERE '{{ task_info.get("TEST_TASK_FANOUT_A", "MISSING") }}' NOT LIKE '%TEST_TASK_FANOUT_ROOT%'
  AND '{{ task_info.get("TEST_TASK_FANOUT_A", "MISSING") }}' != 'MISSING'

UNION ALL
SELECT 'test_task_fanout_b should have test_task_fanout_root as predecessor' AS failure_reason
WHERE '{{ task_info.get("TEST_TASK_FANOUT_B", "MISSING") }}' NOT LIKE '%TEST_TASK_FANOUT_ROOT%'
  AND '{{ task_info.get("TEST_TASK_FANOUT_B", "MISSING") }}' != 'MISSING'

-- Validate standalone root has a schedule (no predecessors)
UNION ALL
SELECT 'test_task_serverless should have no predecessors' AS failure_reason
WHERE '{{ task_info.get("TEST_TASK_SERVERLESS", "MISSING") }}' NOT IN ('[]', 'MISSING')
  AND '{{ task_info.get("TEST_TASK_SERVERLESS", "MISSING") }}' != ''
