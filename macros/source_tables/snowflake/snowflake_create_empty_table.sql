{% macro snowflake_create_empty_table(relation, source_node) %}

    {%- set columns = source_node.columns.values() %}

    create or replace table {{ relation.include(database=(not temporary), schema=(not temporary)) }} (
        {% if columns|length == 0 %}
            value variant,
        {% else -%}
        {%- for column in columns -%}
            {{column.name}} {{column.data_type}},
        {% endfor -%}
        {% endif %}
            metadata_filename varchar,
            metadata_file_row_number bigint,
            _dbt_copied_at timestamp
    );

{% endmacro %}
