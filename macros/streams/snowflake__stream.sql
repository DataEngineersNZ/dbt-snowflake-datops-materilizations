/*
  This materialization is used for creating stream objects.
  The idea behind this materialization is for ability to define streams ddl  and have dbt use the necessary logic
  of deploying the stream in a consistent manner and logic.
*/

{%- materialization stream, adapter='snowflake' -%}

  {%- set source_model = config.get('source_model') -%}
  {%- set source_schema = config.get('source_schema', default=schema) -%}
  {%- set source_database = config.get('source_database', default=database) -%}
  {%- set source_materalization = config.get('source_materalization', default="TABLE") %}
  {%- set source_type = config.get('source_type', default='internal') -%}
  {%- set append_only = config.get('append_only', default=False) -%}
  {%- set insert_only = config.get('insert_only', default=False) -%}
  {%- set copy_grants = config.get('copy_grants', default=False) -%}
  {%- set show_initial_rows = config.get('show_initial_rows', default=False) -%}
  
  {% set target_relation = this %}
  {% set source_relation = adapter.get_relation(identifier=source_model, schema=source_schema, database=source_database) %}

  {% if source_relation == none %}
    {% set source_relation = api.Relation.create(identifier=source_model, schema=source_schema, database=database) %} 
  {% endif %}
  
  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  -- action statement

  {%- call statement('main') -%}
    {% if source_type == 'external' %}
      {{ dbt_dataengineers_materializations.snowflake_create_external_stream_statement(source_materalization, target_relation, source_relation, copy_grants, insert_only, append_only, show_initial_rows) }}
    {% else %}
      {{ dbt_dataengineers_materializations.snowflake_create_stream_statement(target_relation, source_relation, copy_grants, append_only, show_initial_rows) }}
    {% endif %}
  {%- endcall -%}


  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}
  
{%- endmaterialization -%}