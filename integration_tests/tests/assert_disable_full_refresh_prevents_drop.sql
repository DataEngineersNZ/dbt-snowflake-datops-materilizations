-- Verifies that the disable_full_refresh property prevents table replacement.
-- This test checks that the source with disable_full_refresh: true is correctly
-- configured in the graph and that its external.disable_full_refresh value is true.

{% if execute %}

{% set found = [] %}
{% for node in graph.sources.values() %}
    {% if node.identifier == 'test_source_table_no_full_refresh' or node.name == 'test_source_table_no_full_refresh' %}
        {% do found.append(node) %}
    {% endif %}
{% endfor %}

{% if found | length == 0 %}
    {# Debug: log available source names #}
    {% set names = [] %}
    {% for node in graph.sources.values() %}
        {% do names.append(node.name ~ ' / ' ~ node.identifier) %}
    {% endfor %}
    {{ exceptions.raise_compiler_error("test_source_table_no_full_refresh source not found in graph. Available sources: " ~ names | join(', ')) }}
{% endif %}

{% set source_node = found[0] %}

-- Verify the disable_full_refresh property is accessible and true
{% if not source_node.external.get('disable_full_refresh', false) %}
    {{ exceptions.raise_compiler_error("disable_full_refresh property is not set to true. external keys: " ~ source_node.external.keys() | list) }}
{% endif %}

-- Get the build plan (first run) - this simulates what happens during on-run-start
{% set build_plan = dbt_dataengineers_materializations.get_source_build_plan(source_node, true, 'internal', true) %}

-- Check that no statement in the build plan contains DROP TABLE for our target table
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
