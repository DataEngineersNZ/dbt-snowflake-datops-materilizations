{%- macro snowflake_create_external_stream_statement(stream_relation, table_relation, copy_grants, insert_only, append_only, show_initial_rows) -%}
    
CREATE STREAM IF NOT EXISTS {{ stream_relation.include(database=(not temporary), schema=(not temporary)) }}
{% if copy_grants %}
COPY GRANTS
{% endif %}
ON EXTERNAL TABLE {{ table_relation.include(database=(not temporary), schema=(not temporary)) }}
INSERT_ONLY = {{ insert_only }}
APPEND_ONLY = {{ append_only }}
SHOW_INITIAL_ROWS = {{ show_initial_rows }};

{%- endmacro -%}