{%- macro snowflake_create_oauth_authorization_code_secret_statement(target_relation, security_integration, oauth_refresh_token, oauth_refresh_token_expiry_time) -%}
create secret if not exists {{ target_relation.include(database=(not temporary), schema=(not temporary)) }}
type = OAUTH2
oauth_refresh_token = '{{ oauth_refresh_token }}'
oauth_refresh_token_expiry_time = '{{ oauth_refresh_token_expiry_time }}'
api_authentication = {{ security_integration }};
{%- endmacro -%}