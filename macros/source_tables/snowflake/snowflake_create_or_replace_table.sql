{% macro snowflake_create_or_replace_table(relation, source_node) %}

    {%- set columns = source_node.columns.values() -%}

    CREATE OR REPLACE TABLE {{ relation.include(database=(not temporary), schema=(not temporary)) }} (
    {%- if columns -%}
        {%- for column in columns %}
            {{column.name}} {{column.data_type}} COMMENT '{{ column.description | replace("'","''")  }}'
            {{- ',' if not loop.last -}}
        {% endfor %}
    {%- endif -%}
);

{% endmacro %}