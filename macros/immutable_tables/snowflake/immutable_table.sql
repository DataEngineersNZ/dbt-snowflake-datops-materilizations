{% materialization immutable_table, adapter='snowflake' -%}

  {% set original_query_tag = set_query_tag() %}

  {% set target_relation = this %}
  {% set existing_relation = load_relation(this) %}
  
  {{ run_hooks(pre_hooks) }}

  {% if (existing_relation is none) %}
      {% set build_sql = dbt_dataengineers_materializations.create_immutable_table_as(target_relation, sql) %}
  {% elif existing_relation.is_view %}
      {#-- Can't overwrite a view with a table - we must drop --#}
      {{ log("Dropping relation " ~ target_relation ~ " because it is a " ~ existing_relation.type ~ " and this model is a immutable table.") }}
      {% do adapter.drop_relation(existing_relation) %}
      {% set build_sql = dbt_dataengineers_materializations.create_immutable_table_as(target_relation, sql) %}
  {% else %}
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
  
  {% do persist_docs(target_relation, model) %}
  
  {% do unset_query_tag(original_query_tag) %}

  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization %}
