{% macro snowflake_create_external_table(relation, source_node) %}
    
    {%- set columns = source_node.columns.values() -%}
    {%- set external = source_node.external -%}
    {%- set partitions = external.partitions -%}

    {%- set is_csv = dbt_dataengineers_materilizations.is_csv(external.file_format) -%}

{# https://docs.snowflake.net/manuals/sql-reference/sql/create-external-table.html #}
{# This assumes you have already created an external stage #}
    CREATE OR REPLACE EXTERNAL TABLE {{ relation.include(database=(not temporary), schema=(not temporary)) }}
    (
        file_name VARCHAR(500) AS metadata$filename,
        load_date TIMESTAMP_LTZ(7) AS current_timestamp{{- ',' if partitions or columns|length > 0 -}}
        {%- if columns or partitions -%}
            {%- if partitions -%}{%- for partition in partitions %}
                {{partition.name}} {{partition.data_type}} AS {{partition.expression}}{{- ',' if not loop.last or columns|length > 0 -}}
            {%- endfor -%}{%- endif -%}
            {%- for column in columns %}
                {%- set column_quoted = adapter.quote(column.name) if column.quote else column.name %}
                {%- set col_expression -%}
                    {%- set col_id = 'value:c' ~ loop.index if is_csv else 'value:' ~ column_quoted -%}
                    (case when is_null_value({{col_id}}) or lower({{col_id}}) = 'null' then null else {{col_id}} end)
                {%- endset %}
                {{column_quoted}} {{column.data_type}} AS ({{col_expression}}::{{column.data_type}})
                {{- ',' if not loop.last -}}
            {% endfor %}
        {%- endif -%}
    )
    {% if partitions %} PARTITION BY ({{partitions|map(attribute='name')|join(', ')}}) {% endif %}
    LOCATION = {{external.location}} {# stage #}
    {% if external.auto_refresh in (true, false) -%}
      AUTO_REFRESH = {{external.auto_refresh}}
    {%- endif %}
    {% if external.pattern -%} PATTERN = '{{external.pattern}}' {%- endif %}
    {% if external.integration -%} INTEGRATION = '{{external.integration}}' {%- endif %}
    FILE_FORMAT = {{external.file_format}}
{% endmacro %}
