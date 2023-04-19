/*
  This materialization is used for creating user defined function objects.
  The idea behind this materialization is for ability to define CREATE user defined function statements and have dbt use the necessary logic
  of deploying the user defined function in a consistent manner and logic.
*/
{%- materialization user_defined_function, adapter='snowflake' -%}
  {%- set preferred_language = config.get('preferred_language', default=SQL) -%}
  {%- set parameters = config.get('parameters', default='') -%}
  {%- set is_secure = config.get('is_secure', default=false) -%}
  {%- set immutable = config.get('immutable', default=false) -%}
  {%- set is_external = config.get('is_external', default=false) -%}
  {%- set api_integration = config.get('api_integration_dev', default='unknown') -%}
  {%- set api_uri = config.get('api_uri_dev', default='unknown') -%}

  {%- if target.name == 'prod' -%}
    {%- set api_uri = config.get('api_uri_prod', default='unknown') -%}
    {%- set api_integration = config.get('api_integration_prod', default='unknown') -%}
  {%- endif -%}

  {%- set sdk_version = config.get('sdk_version', default=null) -%}
  {%- set import_Path = config.get('import_Path', default=null) -%}
  {%- set packages = config.get('packages', default=null) -%}
  {%- set handler_name = config.get('handler_name', default=null) -%}
  {%- set imports = config.get('imports', default=null) -%}
  {%- set target_path = config.get('target_path', default=null) -%}
  {%- set runtime_version = config.get('runtime_version', default=null) -%}

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
    {% if is_external %}
      {{ dbt_dataengineers_materializations.snowflake_create_external_user_defined_functions_statement(target_relation, is_secure, immutable, parameters, return_type, api_integration, api_uri) }}
    {% else %}
      {{ dbt_dataengineers_materializations.snowflake_create_user_defined_functions_statement(target_relation, is_secure, preferred_language, immutable, parameters, return_type, sdk_version, import_Path, packages, handler_name, imports, target_path, runtime_version, sql) }}
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
