{% materialization immutable_table, adapter='snowflake' -%}

    {% set original_query_tag = set_query_tag() %}
    {%- set is_transient = dbt_dataengineers_materializations.config_meta_get('transient', false) -%}
    {%- set if_not_exists = dbt_dataengineers_materializations.config_meta_get('if_not_exists', true) -%}
    {%- set create_or_replace = dbt_dataengineers_materializations.config_meta_get('create_or_replace', false) -%}
    {%- set data_retention_in_days = dbt_dataengineers_materializations.config_meta_get('data_retention_in_days ', none) -%}
    {%- set max_data_extension_in_days = dbt_dataengineers_materializations.config_meta_get('max_data_extension_in_days ', none) -%}
    {%- set enable_change_tracking = dbt_dataengineers_materializations.config_meta_get('change_tracking', false) -%}
    {%- set is_hybrid = dbt_dataengineers_materializations.config_meta_get('is_hybrid', false) -%}
    {%- set grant_config = config.get('grants') %}

    {% if create_or_replace %}
        {% set create_statement = "create or replace" %}
    {% else %}
        {% set create_statement = "create" %}
    {% endif %}

    {% if is_transient %}
        {% set create_statement = create_statement ~ " transient table"%}
        {% set allow_transient_removal = false %}
    {% elif is_hybrid %}
        {% set create_statement = create_statement ~ " hybrid table"%}
        {% set allow_transient_removal = false %}
    {% else %}
        {% set create_statement = create_statement ~ " table"%}
        {% set allow_transient_removal = true %}
    {% endif %}

    {% if if_not_exists and not create_or_replace  %}
        {% set create_statement = create_statement ~ " if not exists"  %}
    {% endif %}

    {% set target_relation = this %}
    {% set existing_relation = load_relation(this) %}

    {{ run_hooks(pre_hooks) }}

    {% if (existing_relation is none or create_or_replace) %}
        {% if is_hybrid %}
            {% set build_sql = dbt_dataengineers_materializations.create_immutable_hybrid_table(target_relation, create_statement, model) %}
        {% else %}
            {% set build_sql = dbt_dataengineers_materializations.create_immutable_table_as(target_relation, create_statement, is_transient, data_retention_in_days, max_data_extension_in_days, enable_change_tracking, sql) %}
        {% endif %}
    {% elif existing_relation.is_view  %}
        {#-- Can't overwrite a view with a table - we must drop --#}
        {{ log("Dropping relation " ~ target_relation ~ " because it is a " ~ existing_relation.type ~ " and this model is a immutable table.") }}
        {% do adapter.drop_relation(existing_relation) %}
        {% if is_hybrid %}
            {% set build_sql = dbt_dataengineers_materializations.create_immutable_hybrid_table(target_relation, create_statement) %}
        {% else %}
            {% set build_sql = dbt_dataengineers_materializations.create_immutable_table_as(target_relation, create_statement, is_transient, data_retention_in_days, max_data_extension_in_days, enable_change_tracking, sql) %}
        {% endif %}
    {% elif dbt_dataengineers_materializations.check_if_transient(existing_relation.schema, existing_relation.identifier) %}
        {% if create_or_replace or allow_transient_removal %}
            {{ log("Dropping relation " ~ target_relation ~ " because it is a transient table.", info=True) }}
            {% do adapter.drop_relation(existing_relation) %}
            {% if is_hybrid %}
                {% set build_sql = dbt_dataengineers_materializations.create_immutable_hybrid_table(target_relation, create_statement) %}
            {% else %}
                {% set build_sql = dbt_dataengineers_materializations.create_immutable_table_as(target_relation, create_statement, is_transient, data_retention_in_days, max_data_extension_in_days, enable_change_tracking, sql) %}
            {% endif %}
        {% endif %}
    {% else %}
       {{ log("ELSE " ~ target_relation, info=True) }}
        {# noop #}
    {% endif %}

    {% if build_sql %}
        {% call statement("main") %}
            {{ build_sql }}
        {% endcall %}
    {% else %}
        {{ store_result('main', 'SKIP') }}
    {% endif %}

    {{ run_hooks(post_hooks) }}

    {% set should_revoke = should_revoke(existing_relation, full_refresh_mode=True) %}
    {% do apply_grants(target_relation, grant_config, should_revoke=should_revoke) %}
    {% do dbt_dataengineers_materializations.persist_table_docs(target_relation, model) %}

    {% do unset_query_tag(original_query_tag) %}

    {{ return({'relations': [target_relation]}) }}

{%- endmaterialization %}

{% macro check_if_transient(schema, table) %}

    {% if execute %}
        {% set is_transient_query %}
            SELECT is_transient
            FROM information_schema.tables
            WHERE table_schema = '{{ schema }}'
              AND table_name = '{{ table }}'
        {% endset %}

        {% set result = run_query(is_transient_query) %}
        {% if result and result | length > 0 %}
            {% set is_transient = result.columns[0].values()[0] == "YES" %}
        {% else %}
            {% set is_transient = false %}
        {% endif %}
    {% else %}
        {% set is_transient = false %}
    {% endif %}

    {{ return(is_transient) }}
{% endmacro %}

{% macro persist_table_docs(target_relation, model) %}

  {% if model.config.persist_docs %}
    {% if model.config.persist_docs.relation %}
      -- Add a comment to the table
      {% call statement("main") %}
          comment on table {{ target_relation }} is $${{ model.description }}$$;
      {% endcall %}

      {% for column in model.columns %}
        -- Add a comment to each column
       {% call statement("main") %}
          comment on column {{ target_relation }}.{{ column }} is $${{ model.columns[column].description }}$$;
       {% endcall %}
      {% endfor %}
    {% endif %}
  {% endif %}
{% endmacro %}