{% macro snowflake__get_external_build_plan(source_node, is_first_run) %}

    {% set build_plan = [] %}

    {%- set migration_table_suffix = '_DBT_MIG' -%}
    {%- set comparison_table_suffix = '_DBT_COMP' -%}

    {%- set current_relation = adapter.get_relation(database=source_node.database, schema=source_node.database, identifier=source_node.identifier) -%}
    {%- set target_relation = api.Relation.create(database=source_node.database, schema=source_node.database, identifier=source_node.name, type='table') -%}
    {%- set migration_relation = make_temp_relation(target_relation , migration_table_suffix) %}
    {%- set comparison_relation = make_temp_relation(target_relation , comparison_table_suffix) %}
    
    {% set create_or_replace = (current_relation is none or var('ext_full_refresh', false)) %}
    {% if is_first_run %}
        {% if source_node.external.get('snowpipe', none) is not none %}
        
            {% if create_or_replace %}
                {% set build_plan = build_plan + [
                    dbt_dataengineers_materilizations.create_external_schema(source_node),
                    dbt_external_tables.snowflake_create_empty_table(target_relation, source_node),
                    dbt_dataengineers_materilizations.snowflake__get_inital_copy_sql(target_relation, source_node, explicit_transaction=true),
                    dbt_external_tables.snowflake_create_snowpipe(target_relation, source_node)
                ] %}
            {% else %}
                {% set build_plan = build_plan + [dbt_dataengineers_materilizations.snowflake_create_or_replace_table(comparison_relation, source_node)] %}
            {% endif %}
        {% else %}
            {% if create_or_replace %}
                {% set build_plan = build_plan + [dbt_dataengineers_materilizations.snowflake__create_external_table(target_relation, source_node)] %}
            {% else %}
                {% set build_plan = build_plan + dbt_external_tables.refresh_external_table(target_relation,source_node) %}
            {% endif %}
        {% endif %}
    {% else %}
        {% if current_relation is not none and  comparison_relation is not none %}
            {%- set new_cols = adapter.get_missing_columns(comparison_relation, current_relation) %}
            {%- set dropped_cols = adapter.get_missing_columns(current_relation ,comparison_relation) %}

            {% if new_cols|length > 0 || dropped_cols|length > 0 -%}
                {% set build_plan = build_plan + [
                    dbt_dataengineers_materilizations.snowflake_drop_pipe(target_relation),
                    dbt_dataengineers_materilizations.snowflake_clone_table_relation_if_exists(current_relation, migration_relation),
                    dbt_dataengineers_materilizations.snowflake_drop_table(current_relation),
                    dbt_external_tables.snowflake_create_empty_table(target_relation, source_node),
                    dbt_dataengineers_materilizations.snowflake_migrate_data(migration_relation, target_relation, source_node),
                    dbt_external_tables.snowflake_create_snowpipe(target_relation, source_node),
                    dbt_dataengineers_materilizations.snowflake_drop_table(migration_relation)
                    ] %}
            {% endif %}

            {% if source_node.external.get('snowpipe', none) is not none %}
                    {# dont do anythin on second run through #}
            {% else %}
                {% set build_plan = build_plan + [dbt_external_tables.snowflake_refresh_snowpipe(target_relation, source_node)] %}
            {% endif %}

            {% set build_plan = build_plan + [dbt_dataengineers_materilizations.snowflake_drop_table(comparison_relation)] %}
            
        {% endif %}
    {% endif %}
    {% do return(build_plan) %}

{% endmacro %}
