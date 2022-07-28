{% macro snowflake_clone_table_relation_if_exists(old_relation ,clone_relation) %}
  {% if old_relation is not none %}
        CREATE OR REPLACE TABLE {{ clone_relation }}
            CLONE {{ old_relation }}
  {% endif %}
{% endmacro %}