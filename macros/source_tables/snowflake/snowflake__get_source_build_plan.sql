{% macro snowflake__get_source_build_plan(source_node, is_first_run, auto_maintained) %}
    {% set build_plan = [] %}

    {# Setup our variables which are re-usable #}
    {%- set identifier = source_node.name -%}
    {%- set schema = source_node.schema -%}
    {%- set database = source_node.database -%}
    {%- set full_refresh_mode = (flags.FULL_REFRESH == True) -%}
    {%- set migration_table_suffix = '_DBT_MIG' -%}
    {%- set comparison_table_suffix = '_DBT_COMP' -%}

    {# setup our model relationships #}
    {%- set current_relation = adapter.get_relation(database=database, schema=schema, identifier=identifier) -%}
    {%- set target_relation = api.Relation.create(database=database, schema=schema, identifier=identifier, type='table') -%}
    {%- set migration_relation = make_temp_relation(target_relation , migration_table_suffix) %}
    {%- set comparison_relation = make_temp_relation(target_relation , comparison_table_suffix) %}

    {% if is_first_run %}

        {%- set current_relation_exists_as_table = (current_relation is not none and current_relation.is_table) -%}
        {%- set current_relation_exists_as_view = (current_relation is not none and current_relation.is_view) -%}
        {%- set create_or_replace = (current_relation is none or full_refresh_mode) -%}
        {%- set stream_name = dbt_dataengineers_materializations.snowflake_get_stream_name(identifier) -%}
        {%- set stream_relation = api.Relation.create(schema=schema, identifier=stream_name) -%}

        {# determine if we need to replace a view with this table #}
        {% if current_relation_exists_as_view %}
            {% do build_plan.append(dbt_dataengineers_materializations.snowflake_drop_view(current_relation)) %}
            {% set current_relation = none %}
        {% endif %}

        {# determine backups and mirgation and comparison tables accoridngly #}
        {% if current_relation_exists_as_table and auto_maintained %}
            {% if source_node.external.retain_previous_version_flg %}
                {%- set backup_suffix_dt = py_current_timestring() -%}
                {%- set backup_table_suffix = config.get('backup_table_suffix', default='_DBT_BACKUP_') -%}
                {%- set backup_identifier = identifier + backup_table_suffix + backup_suffix_dt -%}
                {%- set backup_relation = api.Relation.create(database=database, schema=schema, identifier=backup_identifier, type='table') -%}
                {% do build_plan.append(dbt_dataengineers_materializations.snowflake_clone_table_relation_if_exists(current_relation, backup_relation)) %}
            {% endif %}
            {% do build_plan.append(dbt_dataengineers_materializations.snowflake_clone_table_relation_if_exists(current_relation, migration_relation)) %}
        {% endif %}
        {# drop and re-create tables as necesary #}
        {% if create_or_replace %}
            {% if current_relation_exists_as_table %}
                {% do build_plan.append(dbt_dataengineers_materializations.snowflake_drop_stream_statement(stream_relation)) %}
                {% do build_plan.append(dbt_dataengineers_materializations.snowflake_drop_table(current_relation)) %}
            {% else %}
                {% do build_plan.append(dbt_dataengineers_materializations.snowflake_create_schema(target_relation)) %}
            {% endif %}
            {% do build_plan.append(dbt_dataengineers_materializations.snowflake_create_or_replace_table(target_relation, source_node)) %}
        {% elif auto_maintained %}
            {% do build_plan.append(dbt_dataengineers_materializations.snowflake_create_or_replace_table(comparison_relation, source_node)) %}
        {% endif %}
    {% elif auto_maintained %}
        {% if current_relation is not none and comparison_relation is not none %}
            {# If we are not doing a full refresh  #}
            {% if not full_refresh_mode %}
                {%- set new_cols = adapter.get_missing_columns(comparison_relation, current_relation) %}
                {%- set dropped_cols = adapter.get_missing_columns(current_relation ,comparison_relation) %}

                {# CASE 1 : New columns were added #}
                {% if new_cols|length > 0 -%}
                    {% for col in new_cols %}
                        {% do build_plan.append(dbt_dataengineers_materializations.snowflake_alter_table_add_column(current_relation, col.name, col.data_type)) %}
                    {% endfor %}
                {%- endif %}

                {# CASE 2 : Columns were dropped #}
                {% if dropped_cols|length > 0 -%}
                    {% for col in dropped_cols %}
                        {% do build_plan.append(dbt_dataengineers_materializations.snowflake_alter_table_drop_column(current_relation, col.name)) %}
                    {% endfor %}
                {%- endif %}

                {# CASE 3 : Columns were renamed #}
                {# This is equivalent of dropped and renamed hence no additional logic needed #}

                {# CASE 4 : Column data type changed #}
                {%- set new_cols_sizing = adapter.get_columns_in_relation(comparison_relation) %}
                {%- set old_cols_sizing = adapter.get_columns_in_relation(current_relation) %}
                {% for new_col in new_cols_sizing %}
                    {% for old_col in old_cols_sizing %}
                        {% if new_col.name == old_col.name and new_col.data_type != old_col.data_type  %}
                            {% do build_plan.append(dbt_dataengineers_materializations.snowflake_alter_table_alter_column(current_relation, old_col.name, new_col.data_type)) %}
                        {% endif %}
                    {% endfor %}
                {% endfor %}

            {% else %}
                {% if source_node.external.migrate_data_over_flg %}
                    {% do build_plan.append(dbt_dataengineers_materializations.snowflake_migrate_data(migration_relation, target_relation, source_node)) %}
                {% endif %}
            {% endif %}
        {% endif %}
        {# Tidy up - drop comparison and migration tables #}
        {% do build_plan.append(dbt_dataengineers_materializations.snowflake_drop_table(migration_relation)) %}
        {% do build_plan.append(dbt_dataengineers_materializations.snowflake_drop_table(comparison_relation)) %}
    {% endif %}


    {% do return(build_plan) %}
{% endmacro %}
