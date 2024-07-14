/*
  This materialization is used for creating user defined function objects.
  The idea behind this materialization is for ability to define create user defined function statements and have dbt use the necessary logic
  of deploying the user defined function in a consistent manner and logic.
*/
{%- materialization user_defined_function, adapter='snowflake' -%}
  {%- set preferred_language = config.get('preferred_language', default='SQL') -%}
  /* common parameters */
  {%- set parameters = config.get('parameters', default='') -%}
  {%- set is_secure = config.get('is_secure', default=false) -%}
  {%- set immutable = config.get('immutable', default=false) -%}
  {%- set return_type = config.get('return_type', default='varchar' ) -%}

  /* end common parameters */
  /* start external functions */
  {%- set is_external = config.get('is_external', default=false) -%}
  {%- set api_integration = config.get('api_integration_dev', default='unknown') -%}
  {%- set api_uri = config.get('api_uri_dev', default='unknown') -%}
  {%- if target.name == 'prod' -%}
    {%- set api_uri = config.get('api_uri_prod', default='unknown') -%}
    {%- set api_integration = config.get('api_integration_prod', default='unknown') -%}
  {%- endif -%}
  /* end external functions */

  /* java only properaties*/
  {%- set target_path = config.get('target_path', default=none) -%}
  /* end java*/
  /* sql only properties*/
  {%- set memoizable = config.get('memoizable', default=none) -%}
  /* end sql*/
  /* java / python*/
  {%- set runtime_version = config.get('runtime_version', default=none) -%}
  {%- set packages = config.get('packages', default=none) -%}
  {%- set external_access_integrations = config.get('external_access_integrations', default=[]) %}
  {%- set external_access_integrations_refs = config.get('external_access_integrations_refs', default=[]) %}
  {%- set secrets = config.get('secrets', default=none) %}
  {%- set handler_name = config.get('handler_name', default=none) -%}
  {%- set imports = config.get('imports', default=null) -%}
  /* end java / python*/

  {%- set null_input_behavior = config.get('null_input_behavior', 'called on null input')%}
  {%- set identifier = config.get('override_name', default=model['alias'] ) -%}
  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}
  {%- set has_transactional_hooks = (hooks | selectattr('transaction', 'equalto', True) | list | length) > 0 %}

  {% for integration in external_access_integrations_refs %}
    {% set integration_name = integration ~ "_" ~  target.name|replace('local-dev', database|replace(var('target_database_replacement'), ''))  %}
    {% do external_access_integrations.append(integration_name) %}
  {% endfor %}
  {% if external_access_integrations|length == 0 %}
    {% set external_access_integrations = none %}
  {% endif %}

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- BEGIN happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

      --------------------------------------------------------------------------------------------------------------------
  -- build model

  {% call statement('main') -%}
    {% if is_external %}
      {{ dbt_dataengineers_materializations.snowflake_create_external_user_defined_functions_statement(target_relation, is_secure, immutable, parameters, return_type, api_integration, api_uri) }}
    {% elif preferred_language|upper == 'JAVA' %}
       {{ dbt_dataengineers_materializations.snowflake_create_java_user_defined_functions_statement(target_relation, is_secure, immutable, parameters, return_type, runtime_version, packages, external_access_integrations, secrets, handler_name, imports, target_path, null_input_behavior, sql) }}
    {% elif preferred_language|upper == 'PYTHON' %}
        {{ dbt_dataengineers_materializations.snowflake_create_python_user_defined_functions_statement(target_relation, is_secure, immutable, parameters, return_type, runtime_version, packages, external_access_integrations, secrets, handler_name, imports, null_input_behavior, sql) }}
    {% elif preferred_language|upper == 'JAVASCRIPT' %}
        {{ dbt_dataengineers_materializations.snowflake_create_javascript_user_defined_functions_statement(target_relation, is_secure, immutable, parameters, return_type, null_input_behavior, sql) }}
    {% else %}
      {{ dbt_dataengineers_materializations.snowflake_create_sql_user_defined_functions_statement(target_relation, is_secure, immutable, parameters, return_type, memoizable, sql) }}
    {% endif %}
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
