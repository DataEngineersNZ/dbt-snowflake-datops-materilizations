{%- macro snowflake_create_stream_statement(source_materalization, stream_relation, table_relation) -%}
    
CREATE STREAM IF NOT EXISTS {{ stream_relation.include(database=(not temporary), schema=(not temporary)) }} 
ON {{ source_materalization || upper }} {{ table_relation.include(database=(not temporary), schema=(not temporary)) }};

{%- endmacro -%}