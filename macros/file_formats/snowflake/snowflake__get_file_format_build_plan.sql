{% macro snowflake__get_file_format_build_plan(source_node) %}

    {% set build_plan = [] %}
        
    {% if source_node.config.materialized == 'file_format' %}
        {% set stage_relation = api.Relation.create(
            database = source_node.database,
            schema = source_node.schema,
            identifier = source_node.name
        ) %}

        {% set sql = render(source_node.get('raw_code')) %}
        {% set build_plan = build_plan + [
                dbt_dataengineers_materilizations.create_external_schema(source_node),
                dbt_dataengineers_materilizations.snowflake_create_fileformat_statement(stage_relation, sql)] %}
        

    {% endif %}
    {% do return(build_plan) %}

{% endmacro %}
