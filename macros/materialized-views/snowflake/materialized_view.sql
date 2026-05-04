{%- materialization snowflake_materialized_view, adapter='snowflake' -%}
  {% set original_query_tag = set_query_tag() %}
  {% set identifier = model['alias'] %}
  {% set full_refresh_mode = (should_full_refresh()) %}
  {% set target_relation = this %}

  {% set existing_relation = adapter.get_relation(database=database, schema=schema, identifier=identifier) %}

  {% set statements = []%}

  {{ run_hooks(pre_hooks) }}
  {% if existing_relation.is_table %}
       {{ log("Dropping relation " ~ target_relation ~ " because it is a " ~ existing_relation.type ~ " and this model is a materialized view.") }}
       {% do adapter.drop_relation(existing_relation) %}
  {% endif %}

  {% if (existing_relation is none or full_refresh_mode or existing_relation.is_table) %}
      {% do statements.append(dbt_dataengineers_materializations.create_materialized_view_as(target_relation, sql, config)) %}
      {% do statements.append(dbt_dataengineers_materializations.apply_clusters(target_relation, config)) %}
      {% do statements.append(dbt_dataengineers_materializations.enable_automatic_clustering(target_relation, config)) %}
  {% else %}
      {# noop #}
  {% endif %}

  {% if statements | length > 0 %}
    {% for sql_statement in statements %}
        {% set sql_statement = sql_statement | trim %}
        {% if sql_statement == '' or sql_statement == 'NONE' %}
            {% continue %}
        {% endif %}
        {% call statement("main") %}
            {{ sql_statement }}
        {% endcall %}
    {% endfor %}
  {% else %}
    {{ store_result('main', 'SKIP') }}
  {% endif %}

  {{ run_hooks(post_hooks) }}

  {% do persist_docs(target_relation, model) %}

  {% do unset_query_tag(original_query_tag) %}

  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}
