{% macro create_immutable_hybrid_table(target_relation, create_statement, model) -%}

{%- set columns = model.columns.values() -%}
{%- set primary_keys = model.config.get("meta", {}).get("primary_keys", []) -%}
{{ create_statement }} {{ target_relation.include(database=(not temporary), schema=(not temporary)) }} (
{%- if columns -%}
    {%- for column in columns %}
        {%- set column_description = column.description | default('') | replace("'","''") -%}
        {%- set primary_key = column.name in primary_keys -%}
        {%- set is_unique = column.get("config", {}).get("meta", {}).get('is_unique', false) -%}
        {%- if primary_key -%}
            {%- set auto_increment = column.get("config", {}).get("meta", {}).get('auto_increment', true) -%}
            {% if auto_increment %}
                {%- set auto_increment_start = column.get("config", {}).get("meta", {}).get('auto_increment_start', 1) -%}
                {%- set auto_increment_increment =  column.get("config", {}).get("meta", {}).get('auto_increment_increment', 1) -%}
                {%- set auto_increment_order =  column.get("config", {}).get("meta", {}).get('auto_increment_order', "order") -%}
                {%- set auto_increment_statement = "autoincrement start " ~ auto_increment_start ~ " increment " ~ auto_increment_increment~ auto_increment_order -%}
            {% else %}
                {%- set auto_increment_statement = "" -%}
            {% endif %}
            {% if primary_keys | length == 1 %}
                {%- set additional_column_detail  = "NOT NULL" ~ (" " ~ auto_increment_statement if auto_increment else "") ~ " PRIMARY KEY COMMENT '" ~ column_description ~ "'" -%}
            {% else %}
                {%- set additional_column_detail  = "NOT NULL" ~ (" " ~ auto_increment_statement if auto_increment else "") ~ " COMMENT '" ~ column_description ~ "'" -%}
            {% endif %}
        {%- elif is_unique -%}
            {%- set additional_column_detail = "UNIQUE COMMENT '" ~ column_description ~ "'" -%}
        {%- else -%}
            {%- set additional_column_detail = "COMMENT '" ~ column_description ~ "'" -%}
        {%- endif -%}
        {{column.name}} {{column.data_type}} {{ additional_column_detail }}
        {{- ',' if not loop.last -}}
    {% endfor %}
    {%- if primary_keys | length > 1 -%}
        , CONSTRAINT {{ target_relation.identifier }}_pk PRIMARY KEY ({{ primary_keys | join(', ') }})
    {%- endif -%}
{%- endif -%}
)
{% endmacro %}