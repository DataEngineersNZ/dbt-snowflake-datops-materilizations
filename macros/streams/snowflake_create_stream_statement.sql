{%- macro snowflake_create_stream_statement(source_materalization, stream_relation, table_relation, copy_grants, append_only, show_initial_rows) -%}
    
CREATE STREAM IF NOT EXISTS {{ stream_relation.include(database=(not temporary), schema=(not temporary)) }}
{% if copy_grants %}
COPY GRANTS
{% endif %}
ON {{ source_materalization || upper }} {{ table_relation.include(database=(not temporary), schema=(not temporary)) }}
APPEND_ONLY = {{ append_only }}
SHOW_INITIAL_ROWS = {{ show_initial_rows }};

{%- endmacro -%}