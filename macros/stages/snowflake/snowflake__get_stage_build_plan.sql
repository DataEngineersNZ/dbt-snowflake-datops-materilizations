{% macro snowflake__get_stage_build_plan(source_node) %}

    {% set build_plan = [] %}
        
    {% if source_node.config.materialized == 'stage' %}
        {% set stage_relation = api.Relation.create(
            database = source_node.database,
            schema = source_node.schema,
            identifier = source_node.name
        ) %}

        {% set sql = render(source_node.get('raw_sql')) %}
        {% set build_plan = build_plan + [dbt_dataengineers_materilizations.snowflake_create_stages_statement(stage_relation, sql)] %}
        

    {% endif %}
    {% do return(build_plan) %}

{% endmacro %}
