{% macro snowflake_drop_table(table_relation) %}
    DROP TABLE IF EXISTS  {{ table_relation }};
{% endmacro %}