{% macro snowflake_create_schema(relation) %}
    CREATE SCHEMA IF NOT EXISTS {{ relation.database }}.{{ relation.schema }}
{% endmacro %}
