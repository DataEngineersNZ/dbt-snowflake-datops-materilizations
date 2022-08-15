{%- macro snowflake_create_external_stream_statement(stream_relation, table_relation) -%}
    
CREATE STREAM IF NOT EXISTS {{ stream_relation.include(database=(not temporary), schema=(not temporary)) }}
ON EXTERNAL TABLE {{ table_relation.include(database=(not temporary), schema=(not temporary)) }}
INSERT_ONLY = TRUE;

{%- endmacro -%}