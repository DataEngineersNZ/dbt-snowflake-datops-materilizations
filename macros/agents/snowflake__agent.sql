/*
  This materialization is used for creating agent objects.
  The idea behind this materialization is for ability to define CREATE OR REPLACE AGENT statements and have dbt use the necessary logic
  of deploying the agent in a consistent manner and logic.
*/

{%- materialization agent, adapter='snowflake' -%}
  {%- set comment = config.get('comment', default=none) -%}
  {%- set profile = config.get('profile', default=none) -%}
  {%- set specification = config.get('specification', default=none) -%}
  {%- set identifier = model['alias'] -%}


  {%- if not specification -%}
    {# Use the model's SQL content as the specification #}
    {%- set specification = sql -%}
    {%- if not specification -%}
      {{ exceptions.raise_compiler_error("Must specify either 'specification', 'specification_file', or put the YAML specification as the model's SQL content.") }}
    {%- endif -%}
  {%- endif -%}


  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- BEGIN happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}

  {% call statement('main') -%}
    {{ dbt_dataengineers_materializations.snowflake_create_or_replace_agent_statement(target_relation, comment, profile, specification) }}
  {%- endcall %}

  -- build model
  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}
  {{ run_hooks(post_hooks, inside_transaction=False) }}

  -- return
  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}