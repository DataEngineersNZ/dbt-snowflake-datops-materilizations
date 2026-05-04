/*
  This materialization is used for secret objects.
*/

{%- materialization secret, adapter='snowflake' -%}
  {%- set secret_type = dbt_dataengineers_materializations.config_meta_get('type', 'GENERIC_STRING') -%}
  {%- set secret_string_variable = dbt_dataengineers_materializations.config_meta_get('secret_string_variable', none) -%}
  {%- set secret_string = none -%}
  {%- set username = dbt_dataengineers_materializations.config_meta_get('username', none) -%}
  {%- set password_variable = dbt_dataengineers_materializations.config_meta_get('password_variable', none) -%}
  {%- set password = none -%}
  {%- set oauth_refresh_token_variable = dbt_dataengineers_materializations.config_meta_get('oauth_refresh_token_variable', none) -%}
  {%- set oauth_refresh_token = none -%}
  {%- set oauth_refresh_token_expiry_time = dbt_dataengineers_materializations.config_meta_get('oauth_refresh_token_expiry_time', none) -%}
  {%- set security_integration = dbt_dataengineers_materializations.config_meta_get('security_integration', none) -%}
  {%- set oauth_scopes = dbt_dataengineers_materializations.config_meta_get('oauth_scopes', none) -%}
  {%- set identifier = model['alias'] -%}

  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}


    -- only run the materialization if it is enabled
    -- setup
    {{ run_hooks(pre_hooks, inside_transaction=False) }}

    -- `BEGIN` happens here:
    {{ run_hooks(pre_hooks, inside_transaction=True) }}

    -- action statement
    {%- call statement('main') -%}
        {%if secret_type|upper == "PASSWORD" %}
            {% set password = env_var(password_variable|upper, '') %}
            {{ dbt_dataengineers_materializations.snowflake_create_password_secret_statement(target_relation, username, password) }}
        {% elif secret_type|upper == "OAUTH2_CLIENT_CREDNTIALS" %}
        {{ dbt_dataengineers_materializations.snowflake_create_oauth_client_credentials_secret_statement(target_relation, security_integration, oauth_scopes) }}
        {% elif secret_type|upper == "OAUTH2_AUTHORIZATION_CODE" %}
            {% set oauth_refresh_token = env_var(oauth_refresh_token_variable, '') %}
            {{ dbt_dataengineers_materializations.snowflake_create_oauth_authorization_code_secret_statement(target_relation, security_integration, oauth_refresh_token, oauth_refresh_token_expiry_time) }}
        {% else %}
            {% set secret_string = env_var(secret_string_variable, '') %}
            {{ dbt_dataengineers_materializations.snowflake_create_generic_secret_statement(target_relation, secret_string) }}
        {% endif %}
    {%- endcall -%}

    {{ run_hooks(post_hooks, inside_transaction=True) }}

    -- `COMMIT` happens here
    {{ adapter.commit() }}

    {{ run_hooks(post_hooks, inside_transaction=False) }}
 

  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}