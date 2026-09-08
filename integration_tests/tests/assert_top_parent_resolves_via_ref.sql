-- depends_on: {{ ref('test_task_root') }}
-- depends_on: {{ ref('test_task_fanout_root') }}
-- Regression test for the 1.0.7 fix: the top-parent relation used to suspend a task
-- must be resolved the same way ref() resolves it (respecting the parent's own
-- configured database/schema), not assumed to share the current model's database.
--
-- This exercises snowflake_get_task_top_parent_node() + ref() for both the
-- 3-level chain (grandchild -> child -> root) and the fan-out chain
-- (fanout_a/fanout_b -> fanout_root), and asserts the resolved relation matches
-- the expected fully-qualified name.

{% set grandchild_node = graph.nodes.values() | selectattr("name", "equalto", "test_task_grandchild") | list | first %}
{% set fanout_a_node = graph.nodes.values() | selectattr("name", "equalto", "test_task_fanout_a") | list | first %}

{% set failures = [] %}

{% if grandchild_node %}
    {% set top_parent = dbt_dataengineers_materializations.snowflake_get_task_top_parent_node(grandchild_node) %}
    {% if not top_parent %}
        {% do failures.append("test_task_grandchild: expected a top parent, found none") %}
    {% elif top_parent.name != "test_task_root" %}
        {% do failures.append("test_task_grandchild: expected top parent 'test_task_root', got '" ~ top_parent.name ~ "'") %}
    {% else %}
        {% set resolved = ref(top_parent.package_name, top_parent.name) %}
        {% if resolved.database != target.database or resolved.schema != target.schema %}
            {% do failures.append("test_task_root resolved via ref() to " ~ resolved ~ " but expected " ~ target.database ~ "." ~ target.schema ~ ".TEST_TASK_ROOT") %}
        {% endif %}
    {% endif %}
{% else %}
    {% do failures.append("test_task_grandchild node not found in graph") %}
{% endif %}

{% if fanout_a_node %}
    {% set top_parent = dbt_dataengineers_materializations.snowflake_get_task_top_parent_node(fanout_a_node) %}
    {% if not top_parent %}
        {% do failures.append("test_task_fanout_a: expected a top parent, found none") %}
    {% elif top_parent.name != "test_task_fanout_root" %}
        {% do failures.append("test_task_fanout_a: expected top parent 'test_task_fanout_root', got '" ~ top_parent.name ~ "'") %}
    {% else %}
        {% set resolved = ref(top_parent.package_name, top_parent.name) %}
        {% if resolved.database != target.database or resolved.schema != target.schema %}
            {% do failures.append("test_task_fanout_root resolved via ref() to " ~ resolved ~ " but expected " ~ target.database ~ "." ~ target.schema ~ ".TEST_TASK_FANOUT_ROOT") %}
        {% endif %}
    {% endif %}
{% else %}
    {% do failures.append("test_task_fanout_a node not found in graph") %}
{% endif %}

{% if failures | length > 0 %}
SELECT failure_reason FROM (
    {% for f in failures %}
    SELECT '{{ f }}' AS failure_reason
    {{ 'UNION ALL' if not loop.last else '' }}
    {% endfor %}
)
{% else %}
SELECT NULL AS failure_reason WHERE 1=0
{% endif %}
