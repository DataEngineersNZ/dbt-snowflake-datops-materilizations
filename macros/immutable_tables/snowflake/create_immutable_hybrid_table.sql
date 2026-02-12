{% macro create_immutable_hybrid_table(node, create_statement) -%}

{%- set columns = node.columns.values() -%}
{{ create_statement }} {{ node.include(database=(not temporary), schema=(not temporary)) }} (
{%- if columns -%}
    {%- for column in columns %}
        {%- set column_description = column.description | replace("'","''") -%}
        {%- set primary_key = column.meta.get('is_primary_key', false) -%}
        {%- set is_unique = column.meta.get('is_unique', false) -%}
        {%- if primary_key -%}
            {%- set auto_increment = column.meta.get('auto_increment', "") -%}
            {%- set additional_column_detail  = "NOT NULL " ~ auto_increment ~ " PRIMARY KEY COMMENT '" ~ column_description ~ "'" -%}
        {%- elif is_unique -%}
            {%- set additional_column_detail = "UNIQUE COMMENT '" ~ column_description ~ "'" -%}
        {%- else -%}
            {%- set additional_column_detail = "COMMENT '" ~ column_description ~ "'" -%}
        {%- endif -%}
        {{column.name}} {{column.data_type}} {{ additional_column_detail }}
        {{- ',' if not loop.last -}}
    {% endfor %}
{%- endif -%}
)
{% endmacro %}