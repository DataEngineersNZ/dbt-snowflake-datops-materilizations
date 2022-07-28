{% macro snowflake_alter_table_drop_column(current_relation, column_name) %}
    ALTER TABLE {{current_relation}} DROP COLUMN {{ column_name }};
{% endmacro %}