/*
  This materialization is used for creating user defined function objects.
  The idea behind this materialization is for ability to define create user defined function statements and have dbt use the necessary logic
  of deploying the user defined function in a consistent manner and logic.
*/
{%- materialization user_defined_function, adapter='snowflake' -%}
  {%- set preferred_language = dbt_dataengineers_materializations.config_meta_get('preferred_language', 'SQL') -%}
  /* common parameters */
  {%- set parameters = dbt_dataengineers_materializations.config_meta_get('parameters', '') -%}
  {%- set is_secure = dbt_dataengineers_materializations.config_meta_get('is_secure', false) -%}
  {%- set immutable = dbt_dataengineers_materializations.config_meta_get('immutable', false) -%}
  {%- set return_type = dbt_dataengineers_materializations.config_meta_get('return_type', 'varchar' ) -%}

  /* end common parameters */
  /* start external functions */
  {%- set is_external = dbt_dataengineers_materializations.config_meta_get('is_external', false) -%}
  {%- set api_integration = dbt_dataengineers_materializations.config_meta_get('api_integration_dev', 'unknown') -%}
  {%- set api_uri = dbt_dataengineers_materializations.config_meta_get('api_uri_dev', 'unknown') -%}
  {%- if target.name == 'prod' -%}
    {%- set api_uri = dbt_dataengineers_materializations.config_meta_get('api_uri_prod', 'unknown') -%}
    {%- set api_integration = dbt_dataengineers_materializations.config_meta_get('api_integration_prod', 'unknown') -%}
  {%- endif -%}
  /* end external functions */

  /* java only properaties*/
  {%- set target_path = dbt_dataengineers_materializations.config_meta_get('target_path', none) -%}
  /* end java*/
  /* sql only properties*/
  {%- set memoizable = dbt_dataengineers_materializations.config_meta_get('memoizable', none) -%}
  /* end sql*/
  /* java / python*/
  {%- set runtime_version = dbt_dataengineers_materializations.config_meta_get('runtime_version', none) -%}
  {%- set packages = dbt_dataengineers_materializations.config_meta_get('packages', none) -%}
  {%- set external_access_integrations = dbt_dataengineers_materializations.config_meta_get('external_access_integrations', []) %}
  {%- set external_access_integrations_refs = dbt_dataengineers_materializations.config_meta_get('external_access_integrations_refs', []) %}
  {%- set secrets = dbt_dataengineers_materializations.config_meta_get('secrets', none) %}
  {%- set handler_name = dbt_dataengineers_materializations.config_meta_get('handler_name', none) -%}
  {%- set imports = dbt_dataengineers_materializations.config_meta_get('imports', none) -%}
  {% if imports is not none -%}
    {% if imports|length == 0 %}
        {% set imports = none %}
    {% endif %}
  {% endif %}
  /* end java / python*/

  {%- set null_input_behavior = dbt_dataengineers_materializations.config_meta_get('null_input_behavior', 'called on null input')%}
  {%- set identifier = dbt_dataengineers_materializations.config_meta_get('override_name', model['alias'] ) -%}
  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}
  {% for integration in external_access_integrations_refs %}
    {% set integration_name = integration ~ "_" ~  target.name|replace('local-dev', database|replace(var('target_database_replacement'), ''))|replace('-', '_')   %}
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
