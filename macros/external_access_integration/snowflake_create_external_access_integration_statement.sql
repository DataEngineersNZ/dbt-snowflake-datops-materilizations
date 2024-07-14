{%- macro snowflake_create_external_access_integration_statement(identifier, authentication_secrets, network_rules, api_authentication_integrations, role_for_creation, roles_for_use) -%}
use role {{ role_for_creation }};
create or replace external access integration {{ identifier }}
allowed_network_rules = ({{ network_rules|join(', ') }})
{%- if authentication_secrets|len > 0 %}
allowed_authentication_secrets = ({{ authentication_secrets|join(', ') }})
{%- endif -%}
{%- if api_authentication_integrations|len > 0 %}
allowed_api_authentication_integrations = ({{ api_authentication_integrations|join(', ') }})
{%- endif -%}
enabled = TRUE;
{% for role in roles_for_use %}
    grant usage on integration {{ identifier }} to role {{ role }};
{% endfor %}
{%- endmacro -%}