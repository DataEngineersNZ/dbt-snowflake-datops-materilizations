{% macro snowflake__get_file_format_build_plan(source_node) %}

    {% set build_plan = [] %}

    {% if source_node.config.materialized == 'file_format' %}
        {% set stage_relation = api.Relation.create(
            database = source_node.database,
            schema = source_node.schema,
            identifier = source_node.name
        ) %}

        {%- set create_or_replace = source_node.config.get('create_or_replace', true) -%}
        {% if create_or_replace %}
            {% set create_statement = "create or replace file format" %}
        {% else %}
            {% set create_statement = "create file format if not exists" %}
        {% endif %}

        {% set sql = render(source_node.get('raw_code')) %}
        {% set build_plan = build_plan + [
                dbt_dataengineers_materializations.create_external_schema(source_node),
                dbt_dataengineers_materializations.snowflake_create_fileformat_statement(create_statement, stage_relation, sql)] %}


    {% endif %}
    {% do return(build_plan) %}

{% endmacro %}
