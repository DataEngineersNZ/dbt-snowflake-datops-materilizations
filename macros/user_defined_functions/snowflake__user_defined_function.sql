/*
  This materialization is used for creating stored procedure objects.
  The idea behind this materialization is for ability to define CREATE STORED PROCEDURE statements and have dbt use the necessary logic
  of deploying the stored procedure in a consistent manner and logic.
  Adapted from https://github.com/venkatra/dbt_hacks

*/
{%- materialization user_defined_function, adapter='snowflake' -%}
  {%- set preferred_language = config.get('preferred_language', default=SQL) -%}
  {%- set parameters = config.get('parameters', default={}) -%}
  {%- set parameters = config.get('is_secure', default=false) -%}
  {%- set parameters = config.get('immutable', default=false) -%}

  {%- set parameters = config.get('sdk_version', default=null) -%}
  {%- set parameters = config.get('import_Path', default=null) -%}
  {%- set parameters = config.get('packages', default=null) -%}
  {%- set parameters = config.get('handler_name', default=null) -%}
  
  {%- set identifier = config.get('override_name', default=model['alias'] ) -%}
  {%- set return_type = config.get('return_type', default='varchar' ) -%}

  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}

  {%- set has_transactional_hooks = (hooks | selectattr('transaction', 'equalto', True) | list | length) > 0 %}

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- BEGIN happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

      --------------------------------------------------------------------------------------------------------------------
  -- build model

  {% call statement('main') -%}
    {{ dbt_dataengineers_materilizations.snowflake_create_user_defined_functions_statement(target_relation, is_secure, preferred_language, immutable, parameters, return_type, sdk_version, import_Path, packages, handler_name, sql) }}

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
