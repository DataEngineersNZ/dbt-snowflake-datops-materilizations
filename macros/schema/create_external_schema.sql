{% macro create_external_schema(source_node) %}
    {{ adapter.dispatch('create_external_schema', 'dbt_dataengineers_materializations')(source_node) }}
{% endmacro %}

{% macro default__create_external_schema(source_node) %}
    {% set ddl %}
        create schema if not exists {{ source_node.database }}.{{ source_node.schema }}
    {% endset %}

    {{return(ddl)}}
{% endmacro %}