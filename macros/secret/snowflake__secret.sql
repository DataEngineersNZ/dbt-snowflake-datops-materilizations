/*
  This materialization is used for secret objects.
*/

{%- materialization secret, adapter='snowflake' -%}
  {%- set secret_type = config.get('type', default='GENERIC_STRING') -%}
  {%- set secret_string_variable = config.get('secret_string_variable', default=none) -%}
  {%- set secret_string = none -%}
  {%- set username = config.get('username', default=none) -%}
  {%- set password_variable = config.get('password_variable', default=none) -%}
  {%- set password = none -%}
  {%- set oauth_refresh_token_variable = config.get('oauth_refresh_token_variable', default=none) -%}
  {%- set oauth_refresh_token = none -%}
  {%- set oauth_refresh_token_expiry_time = config.get('oauth_refresh_token_expiry_time', default=none) -%}
  {%- set security_integration = config.get('security_integration', default=none) -%}
  {%- set oauth_scopes = config.get('oauth_scopes', default=none) -%}

  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}


    -- only run the materialization if it is enabled
    -- setup
    {{ run_hooks(pre_hooks, inside_transaction=False) }}

    -- `BEGIN` happens here:
    {{ run_hooks(pre_hooks, inside_transaction=True) }}

    -- action statement
    {%- call statement('main') -%}
        {%if secret_type|upper == "PASSWORD" %}
            {% set password = env_var('DBT_ENV_SECRET_' ~ password_variable|upper, '') %}
            {{ dbt_dataengineers_materializations.snowflake_create_password_secret_statement(target_relation, username, password) }}
        {% elif secret_type|upper == "OAUTH2_CLIENT_CREDNTIALS" %}
        {{ dbt_dataengineers_materializations.snowflake_create_oauth_client_credentials_secret_statement(target_relation, security_integration, oauth_scopes) }}
        {% elif secret_type|upper == "OAUTH2_AUTHORIZATION_CODE" %}
            {% set oauth_refresh_token = env_var('DBT_ENV_SECRET_' ~ oauth_refresh_token_variable, '') %}
            {{ dbt_dataengineers_materializations.snowflake_create_oauth_authorization_code_secret_statement(target_relation, security_integration, oauth_refresh_token, oauth_refresh_token_expiry_time) }}
        {% else %}
            {% set secret_string = env_var('DBT_ENV_SECRET_' ~ secret_string_variable, '') %}
            {{ dbt_dataengineers_materializations.snowflake_create_generic_secret_statement(target_relation, secret_string) }}
        {% endif %}
    {%- endcall -%}

    {{ run_hooks(post_hooks, inside_transaction=True) }}

    -- `COMMIT` happens here
    {{ adapter.commit() }}

    {{ run_hooks(post_hooks, inside_transaction=False) }}
 

  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}