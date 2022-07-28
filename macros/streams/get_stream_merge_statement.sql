{% macro get_stream_merge_statement(source, destination_table, unique_key) -%}

{% set source_relation = load_relation(source) %}
{%- set destination_relation = adapter.get_relation( identifier=destination_table, schema=schema, database=database) -%} 

{% set dest_columns = adapter.get_columns_in_relation(destination_relation) %}

{{ get_merge_sql(destination_relation, source_relation, unique_key, dest_columns) }}

{% endmacro -%}