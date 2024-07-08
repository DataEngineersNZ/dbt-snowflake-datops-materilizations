{%- macro snowflake_create_oauth_client_credentials_secret_statement(target_relation, security_integration, oauth_scopes) -%}
create secret if not exists {{ target_relation.include(database=(not temporary), schema=(not temporary)) }}
type = OAUTH2
oauth_scopes = ('{{ oauth_scopes|join(', ') }}')
api_authentication = {{ security_integration }};
{%- endmacro -%}