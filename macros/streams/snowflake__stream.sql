/*
  This materialization is used for creating stream objects.
  The idea behind this materialization is for ability to define streams ddl  and have dbt use the necessary logic
  of deploying the stream in a consistent manner and logic.
*/

{%- materialization stream, adapter='snowflake' -%}

  {%- set source_model = config.get('source_model') -%}
  {%- set source_schema = config.get('source_schema', default=schema) -%}
  
  {% set target_relation = this %}
  {% set existing_relation = load_relation(this) %}
  {% set source_relation = adapter.get_relation( identifier=source_model, schema=source_schema, database=database) %} 

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  -- action statement

  {%- call statement('main') -%}
    {{ dbt_dataengineers_materilizations.snowflake_create_stream_statement(target_relation, source_relation) }}
  {%- endcall -%}


  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}
  
{%- endmaterialization -%}