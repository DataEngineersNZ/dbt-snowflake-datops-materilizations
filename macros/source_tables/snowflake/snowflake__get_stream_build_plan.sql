{% macro snowflake__get_stream_build_plan(source_node) %}
    {% set build_plan = [] %}

    {# Setup our variables which are re-usable #}
    {%- set identifier = source_node.name -%}
    {%- set schema = source_node.schema -%}
    {%- set database = source_node.database -%}
    {%- set stream_name = dbt_dataengineers_utils_materilizations.snowflake_get_stream_name(identifier) -%}

    {%- set target_relation = api.Relation.create(database=database, schema=schema, identifier=identifier) -%}
    {%- set target_stream_relation = api.Relation.create(database=database, schema=schema, identifier=stream_name) -%}
    
    {% do build_plan.append(dbt_dataengineers_utils_materilizations.snowflake_create_stream_statement(target_stream_relation, target_relation)) %}

    {% do return(build_plan) %}
{% endmacro %}
