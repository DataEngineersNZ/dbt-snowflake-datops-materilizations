/*
  This materialization is used for network rule objects.
*/

{%- materialization external_access_integration, adapter='snowflake' -%}
  {%- set authentication_secrets = config.get('authentication_secrets', default=[]) -%}
  {%- set network_rules = config.get('network_rules', default=[]) -%}
  {%- set api_authentication_integrations = config.get('api_authentication_integrations', default=[]) -%}
  {%- set role_for_creation = config.get('role_for_creation', default='developers') -%}
  {%- set roles_for_use = config.get('roles_for_use', default=['dataops_admin']) -%}
  {%- set identifier = model['alias'] ~ "_" ~  target.name  %}
  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  -- action statement

  {%- call statement('main') -%}
      {{ dbt_dataengineers_materializations.snowflake_create_external_access_integration_statement(identifier|upper, authentication_secrets, network_rules, api_authentication_integrations, role_for_creation, roles_for_use) }}
  {%- endcall -%}


  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [identifier]}) }}

{%- endmaterialization -%}