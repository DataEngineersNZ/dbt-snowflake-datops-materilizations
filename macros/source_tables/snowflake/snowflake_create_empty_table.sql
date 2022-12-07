{% macro snowflake_create_empty_table(relation, source_node) %}

    {%- set columns = source_node.columns.values() %}

    CREATE OR REPLACE TABLE {{ relation.include(database=(not temporary), schema=(not temporary)) }} (
        {% if columns|length == 0 %}
            payload VARIANT,
        {% else -%}
        {%- for column in columns -%}
            {%- if column.name|lower not in ["metadata_filename", "metadata_file_row_number", "import_timestamp"] -%}
            {{column.name}} {{column.data_type}}
            {%- endif -%}
        {% endfor -%}
        {% endif %}
        metadata_filename VARCHAR,
        metadata_file_row_number BIGINT,
        import_timestamp TIMESTAMP
    );

{% endmacro %}
