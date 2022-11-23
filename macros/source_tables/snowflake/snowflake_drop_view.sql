{% macro snowflake_drop_view(view_relation) %}
    DROP VIEW IF EXISTS  {{ view_relation }};
{% endmacro %}