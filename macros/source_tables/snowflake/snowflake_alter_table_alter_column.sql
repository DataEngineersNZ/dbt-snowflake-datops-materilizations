{% macro snowflake_alter_table_alter_column(current_relation, column_name, data_type) %}
    ALTER TABLE {{current_relation}} ALTER COLUMN {{ column_name }} {{ data_type}};
{% endmacro %}