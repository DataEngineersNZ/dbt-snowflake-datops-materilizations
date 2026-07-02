-- Verifies that the disable_full_refresh property prevents table replacement.
-- Uses full_refresh_mode_override=true to simulate a --full-refresh run during dbt test.

{% if execute %}

{% set source_nodes = graph.sources.values() if graph.sources else [] %}
{% set found = [] %}
{% for node in source_nodes %}
    {% if node.identifier == 'test_source_table_no_full_refresh' or node.name == 'test_source_table_no_full_refresh' %}
        {% do found.append(node) %}
    {% endif %}
{% endfor %}

{% if found | length == 0 %}
    {% set names = [] %}
    {% for node in source_nodes %}
        {% do names.append(node.name ~ ' / ' ~ node.identifier) %}
    {% endfor %}
    {{ exceptions.raise_compiler_error("test_source_table_no_full_refresh source not found in graph. Available sources: " ~ names | join(', ')) }}
{% endif %}

{% set source_node = found[0] %}

{% if not source_node.external.get('disable_full_refresh', false) %}
    {{ exceptions.raise_compiler_error("disable_full_refresh property is not set to true. external keys: " ~ source_node.external.keys() | list) }}
{% endif %}

-- Get the build plan with full_refresh_mode_override=true to simulate --full-refresh
{% set build_plan = dbt_dataengineers_materializations.get_source_build_plan(source_node, true, 'internal', true, full_refresh_mode_override=true) %}

-- Check that no statement in the build plan contains DROP TABLE for our target table.
-- With disable_full_refresh=true, the table should NOT be dropped even under full refresh.
{% set has_drop = [] %}
{% for stmt in build_plan %}
    {% if 'DROP TABLE' in stmt | upper and 'TEST_SOURCE_TABLE_NO_FULL_REFRESH' in stmt | upper %}
        {% do has_drop.append(true) %}
    {% endif %}
{% endfor %}

-- This test returns rows on FAILURE
SELECT 1
WHERE {{ has_drop | length }} > 0

{% else %}
SELECT 1 WHERE 1 = 0
{% endif %}
