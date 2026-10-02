{% macro create_test_schema() %}
    {% set sql %}
        CREATE SCHEMA IF NOT EXISTS {{ target.database }}.{{ target.schema }}
    {% endset %}
    {% do run_query(sql) %}
    {{ log("Created schema: " ~ target.database ~ "." ~ target.schema, info=True) }}
{% endmacro %}
