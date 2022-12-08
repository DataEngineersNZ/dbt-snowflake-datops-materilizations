{% macro snowflake_get_copy_sql(relation, source_node, explicit_transaction=false) %}
{# This assumes you have already created an external stage #}

    {%- set columns = source_node.columns.values() -%}
    {%- set external = source_node.external -%}
    {%- set is_csv = dbt_dataengineers_materilizations.is_csv(external.file_format, relation.database) %}
    {%- set copy_options = external.snowpipe.get('copy_options', none) -%}
    {%- if explicit_transaction -%} begin; {%- endif %}
    
    COPY INTO {{ relation.include(database=(not temporary), schema=(not temporary)) }}
    FROM ( 
        SELECT
        {% if columns|length == 0 %}
            $1::VARIANT AS payload,
        {% else -%}
        {%- for column in columns -%}
            {%- if column.name|lower not in ["metadata_filename", "metadata_file_row_number", "import_timestamp"] -%}
            {%- set col_expression -%}
                {%- if is_csv -%}nullif(${{loop.index}},''){# special case: get columns by ordinal position #}
                {%- elif column.name|lower == "payload" -%}$1
                {%- else -%}nullif($1:{{column.name}},''){# standard behavior: get columns by name #}
                {%- endif -%}
            {%- endset -%}
            {{col_expression}}::{{column.data_type}} AS {{column.name}},
            {% endif -%}    
        {% endfor -%}
        {% endif %}
        metadata$filename::VARCHAR AS metadata_filename,
        metadata$file_row_number::BIGINT AS metadata_file_row_number,
        current_timestamp::timestamp_ltz AS import_timestamp
        FROM {{external.location | replace("@", "@" ~ relation.database ~ ".")}} {# stage #}
    )
    FILE_FORMAT = {{relation.database ~ "." ~ external.file_format}}
    {% if external.pattern -%} pattern = '{{external.pattern}}' {%- endif %}
    {% if copy_options %} {{copy_options}} {% endif %};
    
    {% if explicit_transaction -%} COMMIT; {%- endif -%}

{% endmacro %}
