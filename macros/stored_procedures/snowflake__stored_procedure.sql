/*
  This materialization is used for creating stored procedure objects.
  The idea behind this materialization is for ability to define create stored procedure statements and have dbt use the necessary logic
  of deploying the stored procedure in a consistent manner and logic.
  Adapted from https://github.com/venkatra/dbt_hacks

*/
{%- materialization stored_procedure, adapter='snowflake' -%}
  {%- set preferred_language = config_meta_get('preferred_language', 'SQL') -%}
  {%- set parameters = config_meta_get('parameters', '') -%}
  {%- set identifier = config_meta_get('override_name', model['alias'] ) -%}
  {%- set return_type = config_meta_get('return_type', 'varchar' ) -%}
  {%- set execute_as = config_meta_get('execute_as', 'owner' ) -%}
  {%- set include_copy_grants = config_meta_get('include_copy_grants', true) -%}

  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- BEGIN happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

      --------------------------------------------------------------------------------------------------------------------
  -- build model

  {% set copy_grants_statement = "" %}
  {% if include_copy_grants %}
       {% set copy_grants_statement = "copy grants" %}
  {% endif %}

  {% call statement('main') -%}
    {{ snowflake_create_stored_procedure_statement(target_relation, copy_grants_statement, preferred_language, parameters, return_type, execute_as, sql) }}
  {%- endcall %}

      --------------------------------------------------------------------------------------------------------------------
  -- build model
  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}
  {{ run_hooks(post_hooks, inside_transaction=False) }}

  -- return
  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}
