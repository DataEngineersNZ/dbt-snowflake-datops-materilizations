/*
  This materialization is used for secret objects.
*/

{%- materialization network_rule, adapter='snowflake' -%}
  {%- set secret_type = config.get('type', default='GENERIC_STRING') -%}
  {%- set secret_string = config.get('secret_string', default=none) -%}
  {%- set username = config.get('username', default=none) -%}
  {%- set password = config.get('password', default=none) -%}
  {%- set oauth_refresh_token = config.get('oauth_refresh_token', default=none) -%}
  {%- set oauth_refresh_token_expiry_time = config.get('oauth_refresh_token_expiry_time', default=none) -%}
  {%- set security_integration = config.get('security_integration', default=none) -%}
  {%- set oauth_scopes = config.get('oauth_scopes', default=none) -%}

  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  -- action statement

  {%- call statement('main') -%}
    {%if secret_type|upper == "PASSWORD" %}
      {{ dbt_dataengineers_materializations.snowflake_create_password_secret_statement(target_relation, username, password) }}
    {% elif secret_type|upper == "OAUTH2_CLIENT_CREDNTIALS" %}
      {{ dbt_dataengineers_materializations.snowflake_create_oauth_client_credentials_secret_statement(target_relation, security_integration, oauth_scopes) }}
    {% elif secret_type|upper == "OAUTH2_AUTHORIZATION_CODE" %}
        {{ dbt_dataengineers_materializations.snowflake_create_oauth_authorization_code_secret_statement(target_relation, security_integration, oauth_refresh_token, oauth_refresh_token_expiry_time) }}
    {% else %}
        {{ dbt_dataengineers_materializations.snowflake_create_generic_secret_statement(target_relation, secret_string) }}
    {% endif %}
  {%- endcall -%}


  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}