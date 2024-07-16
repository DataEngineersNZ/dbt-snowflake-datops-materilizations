    /*
  This materialization is used for external access integration objects.
*/

{%- materialization external_access_integration, adapter='snowflake' -%}
  {%- set authentication_secrets = config.get('authentication_secrets', default=[]) -%}
  {%- set authentication_secrets_refs = config.get('authentication_secrets_refs', default=[]) -%}
  {%- set network_rules = config.get('network_rules', default=[]) -%}
  {%- set network_rules_refs = config.get('network_rules_refs', default=[]) -%}
  {%- set api_authentication_integrations = config.get('api_authentication_integrations', default=[]) -%}
  {%- set api_authentication_integrations_refs = config.get('api_authentication_integrations_refs', default=[]) -%}
  {%- set role_for_creation = config.get('role_for_creation', default='developers') -%}
  {%- set roles_for_use = config.get('roles_for_use', default=['dataops_admin']) -%}
  {%- set identifier = model['alias'] ~ "_" ~  target.name|replace('local-dev', database|replace(var('target_database_replacement'), '')|replace('-', '_'))  %}

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  {% set get_current_role_results = run_query("select current_role() as role") %}
  {% set ns = namespace(original_role='unknown') %}
  {% for result in get_current_role_results %}
    {% set ns.original_role = result.values()[0] %}
  {% endfor %}
  -- action statement
 {% for seret_name in authentication_secrets_refs %}
       {% do authentication_secrets.append(builtins.ref(seret_name).include(database=true)) %}
 {% endfor %}
 {% for rule_name in network_rules_refs %}
       {% do network_rules.append(builtins.ref(rule_name).include(database=true)) %}
 {% endfor %}
 {% for api_integration_name in api_authentication_integrations_refs %}
       {% do api_authentication_integrations.append(builtins.ref(api_integration_name).include(database=true)) %}
 {% endfor %}

  {%- call statement('main') -%}
      {{ dbt_dataengineers_materializations.snowflake_create_external_access_integration_statement(identifier|upper, authentication_secrets, network_rules, api_authentication_integrations, role_for_creation, ns.original_role, roles_for_use) }}
  {%- endcall -%}


  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': []}) }}

{%- endmaterialization -%}
