{%- macro snowflake_create_external_access_integration_statement(identifier, authentication_secrets, network_rules, api_authentication_integrations, role_for_creation, original_role, roles_for_use) -%}
{% if target.name in ['local-dev'] %}
use role {{ role_for_creation }};
{% endif %}
create or replace external access integration {{ identifier }}
allowed_network_rules = ({{ network_rules|join(', ') }})
{%- if authentication_secrets|length > 0 %}
allowed_authentication_secrets = ({{ authentication_secrets|join(', ') }})
{%- endif %}
{%- if api_authentication_integrations|length > 0 %}
allowed_api_authentication_integrations = ({{ api_authentication_integrations|join(', ') }})
{%- endif %}
enabled = TRUE;
{% for role in roles_for_use %}
    grant usage on integration {{ identifier }} to role {{ role }};
{% endfor %}
{% if target.name in ['local-dev'] %}
use role {{ original_role }};
{% endif%}
{%- endmacro -%}