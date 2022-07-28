{% macro snowflake_drop_stream_statement(stream_relation) %}
   DROP STREAM IF EXISTS {{ stream_relation }}
{% endmacro %}