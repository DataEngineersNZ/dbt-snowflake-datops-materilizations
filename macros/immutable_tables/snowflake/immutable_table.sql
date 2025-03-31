{% materialization immutable_table, adapter='snowflake' -%}

  {% set original_query_tag = set_query_tag() %}

  {% set target_relation = this %}
  {% set existing_relation = load_relation(this) %}
  
  {{ run_hooks(pre_hooks) }}

{{ log("relation " ~ target_relation ~ " because it is a " ~ existing_relation.type ~ " and this model is a immutable table.", info=True) }}
  {% if (existing_relation is none) %}
      {% set build_sql = dbt_dataengineers_materializations.create_immutable_table_as(target_relation, sql) %}
  {% elif existing_relation.is_view  %}
      {#-- Can't overwrite a view with a table - we must drop --#}
      {{ log("Dropping relation " ~ target_relation ~ " because it is a " ~ existing_relation.type ~ " and this model is a immutable table.") }}
      {% do adapter.drop_relation(existing_relation) %}
      {% set build_sql = dbt_dataengineers_materializations.create_immutable_table_as(target_relation, sql) %}
  {% elif dbt_dataengineers_materializations.check_if_transient(existing_relation.schema, existing_relation.identifier) %}
       {{ log("Dropping relation " ~ target_relation ~ " because it is a transiant table.") }}
      {% do adapter.drop_relation(existing_relation) %}
      {% set build_sql = dbt_dataengineers_materializations.create_immutable_table_as(target_relation, sql) %}
  {% endif %}

  {% if build_sql %}
      {% call statement("main") %}
          {{ build_sql }}
      {% endcall %}
  {% else %}
    {{ store_result('main', 'SKIP') }}
  {% endif %}

  {{ run_hooks(post_hooks) }}

  {% do dbt_dataengineers_materializations.persist_table_docs(target_relation, model) %}

  {% do unset_query_tag(original_query_tag) %}

  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization %}

{% macro check_if_transient(schema, table) %}

    {% set is_transient_query %}
        SELECT is_transient
        FROM information_schema.tables
        WHERE table_schema = '{{ schema }}'
          AND table_name = '{{ table }}'
    {% endset %}

    {% set result = run_query(is_transient_query) %}
    {% set is_transient = result.columns[0].values()[0] %}

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