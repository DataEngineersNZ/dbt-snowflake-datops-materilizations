/*
  This materialization is used for creating stored procedure objects.
  The idea behind this materialization is for ability to define create stored procedure statements and have dbt use the necessary logic
  of deploying the stored procedure in a consistent manner and logic.
  Adapted from https://github.com/venkatra/dbt_hacks

*/
{%- materialization stored_procedure, adapter='snowflake' -%}
  {%- set preferred_language = config.get('preferred_language', default=SQL) -%}
  {%- set parameters = config.get('parameters', default='') -%}
  {%- set identifier = config.get('override_name', default=model['alias'] ) -%}
  {%- set return_type = config.get('return_type', default='varchar' ) -%}
  {%- set execute_as = config.get('execute_as', default='owner' ) -%}
  {%- set include_copy_grants = config.get('include_copy_grants', default=true) -%}

  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}

  {%- set has_transactional_hooks = (hooks | selectattr('transaction', 'equalto', True) | list | length) > 0 %}

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
    {{ dbt_dataengineers_materializations.snowflake_create_stored_procedure_statement(target_relation, copy_grants_statement, preferred_language, parameters, return_type, execute_as, sql) }}
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
