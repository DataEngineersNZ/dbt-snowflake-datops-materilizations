{% macro cleanup() %}
    {% set sql %}
        DROP SCHEMA IF EXISTS {{ target.database }}.{{ target.schema }} CASCADE
    {% endset %}
    {% do run_query(sql) %}
    {{ log("Cleaned up schema: " ~ target.database ~ "." ~ target.schema, info=True) }}
{% endmacro %}
