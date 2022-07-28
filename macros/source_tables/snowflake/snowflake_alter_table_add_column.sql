{% macro snowflake_alter_table_add_column(current_relation, column_name, data_type) %}
    ALTER TABLE {{current_relation}} add column {{ column_name }} {{ data_type}};
{% endmacro %}