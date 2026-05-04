    /*
  This materialization is used for external access integration objects.
*/

{%- materialization external_access_integration, adapter='snowflake' -%}
  {%- set authentication_secrets = dbt_dataengineers_materializations.config_meta_get('authentication_secrets', []) -%}
  {%- set authentication_secrets_refs = dbt_dataengineers_materializations.config_meta_get('authentication_secrets_refs', []) -%}
  {%- set network_rules = dbt_dataengineers_materializations.config_meta_get('network_rules', []) -%}
  {%- set network_rules_refs = dbt_dataengineers_materializations.config_meta_get('network_rules_refs', []) -%}
  {%- set api_authentication_integrations = dbt_dataengineers_materializations.config_meta_get('api_authentication_integrations', []) -%}
  {%- set api_authentication_integrations_refs = dbt_dataengineers_materializations.config_meta_get('api_authentication_integrations_refs', []) -%}
  {%- set role_for_creation = dbt_dataengineers_materializations.config_meta_get('role_for_creation', 'developers') -%}
  {%- set roles_for_use = dbt_dataengineers_materializations.config_meta_get('roles_for_use', ['dataops_admin']) -%}
  {%- set identifier = model['alias'] ~ "_" ~  target.name|replace('local-dev', database|replace(var('target_database_replacement'), ''))|replace('-', '_')  %}

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  {% set ns = namespace(original_role='unknown') %}
  {% if execute %}
    {% set get_current_role_results = run_query("select current_role() as role") %}
    {% for result in get_current_role_results %}
      {% set ns.original_role = result.values()[0] %}
    {% endfor %}
  {% endif %}
  -- action statement
 {% for seret_name in authentication_secrets_refs %}
       {% do authentication_secrets.append(ref(seret_name).include(database=true)) %}
 {% endfor %}
 {% for rule_name in network_rules_refs %}
       {% do network_rules.append(ref(rule_name).include(database=true)) %}
 {% endfor %}
 {% for api_integration_name in api_authentication_integrations_refs %}
       {% do api_authentication_integrations.append(ref(api_integration_name).include(database=true)) %}
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
