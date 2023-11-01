{%- macro snowflake_create_user_defined_functions_statement(relation, is_secure, preferred_language, immutable, parameters, return_type, sdk_version, import_Path, packages, external_access_integrations, secrets, handler_name, imports, target_path,runtime_version, sql) -%}

{% if is_secure  %}
CREATE OR REPLACE SECURE FUNCTION {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ parameters }})
{% else %}
CREATE OR REPLACE FUNCTION {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ parameters }})
{% endif %}
RETURNS {{ return_type }}
{% if preferred_language != 'sql' -%}
LANGUAGE  {{ preferred_language }}
{%- endif %}
{% if immutable %}
IMMUTABLE
{% else %}
VOLATILE
{%- endif -%}

{% if preferred_language == 'python' %}
RUNTIME_VERSION = '{{ runtime_version }}'
HANDLER = '{{ handler_name }}'
PACKAGES = ('{{ packages|join('\', \'') }}')
{% if external_access_integrations is not none -%}
EXTERNAL_ACCESS_INTEGRATIONS = ({{ external_access_integrations }})
{%- endif %}
{% if secrets is not none -%}
SECRETS = ({{ secrets|join(', ') }})
{%- endif %}
{% if import_Path is not none -%}
{%- endif %}
{%- elif preferred_language == 'java' -%}
handler = {{ handler_name }}
target_path = {{ target_path }}
{%- endif %}

AS

$$
 {{ sql }}
 $$
;
{%- endmacro -%}
