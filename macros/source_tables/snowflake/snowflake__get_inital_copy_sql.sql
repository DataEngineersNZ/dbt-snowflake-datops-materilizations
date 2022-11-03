{% macro snowflake__get_inital_copy_sql(relation, source_node, explicit_transaction=false) %}
{# This assumes you have already created an external stage #}

    {%- set columns = source_node.columns.values() -%}
    {%- set external = source_node.external -%}
    {%- set is_csv = dbt_external_tables.is_csv(external.file_format, relation.database) %}
    {%- set copy_options = external.snowpipe.get('copy_options', none) -%}
   
    {%- if explicit_transaction -%} begin; {%- endif %}
    
    copy into {{ relation.include(database=(not temporary), schema=(not temporary)) }}
    from ( 
        select
        {% if columns|length == 0 %}
            $1::variant as value,
        {% else -%}
        {%- for column in columns -%}
            {%- set col_expression -%}
                {%- if is_csv -%}nullif(${{loop.index}},''){# special case: get columns by ordinal position #}
                {%- else -%}nullif($1:{{column.name}},''){# standard behavior: get columns by name #}
                {%- endif -%}
            {%- endset -%}
            {{col_expression}}::{{column.data_type}} as {{column.name}},
        {% endfor -%}
        {% endif %}
            metadata$filename::varchar as metadata_filename,
            metadata$file_row_number::bigint as metadata_file_row_number,
            current_timestamp::timestamp as _dbt_copied_at
        from {{external.location | replace("@", "@" ~ relation.database ~ ".")}} {# stage #}
    )
    file_format = {{relation.database ~ "." ~ external.file_format}}
    {% if external.pattern -%} pattern = '{{external.pattern}}' {%- endif %}
    {% if copy_options %} {{copy_options}} {% endif %};
    
    {% if explicit_transaction -%} commit; {%- endif -%}

{% endmacro %}
