{% macro snowflake__get_stage_build_plan(source_node) %}

    {% set build_plan = [] %}

    {% if source_node.config.materialized == 'stage' %}
        {% set stage_relation = api.Relation.create(
            database = source_node.database,
            schema = source_node.schema,
            identifier = source_node.name
        ) %}
        {% set create_or_replace = source_node.config.get('meta', {}).get('create_or_replace', source_node.config.get('create_or_replace', false)) %}

        {% set sql = render(source_node.get('raw_code')) %}
        {% if create_or_replace %}
            {% set build_plan = build_plan + [dbt_dataengineers_materializations.snowflake_create_or_replace_stage_statement(stage_relation, sql)] %}
        {% else %}
            {% set build_plan = build_plan + [dbt_dataengineers_materializations.snowflake_create_stages_if_not_exist_statement(stage_relation, sql)] %}
        {% endif %}

    {% endif %}
    {% do return(build_plan) %}

{% endmacro %}
