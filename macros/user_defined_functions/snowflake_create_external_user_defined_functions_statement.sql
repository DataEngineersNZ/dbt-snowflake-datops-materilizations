{%- macro snowflake_create_external_user_defined_functions_statement(relation, is_secure, immutable, parameters, return_type, api_integration, api_uri) -%}

{% if is_secure  %}
CREATE SECURE EXTERNAL FUNCTION IF NOT EXISTS {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ parameters }})
{% else %}
CREATE  EXTERNAL FUNCTION IF NOT EXISTS {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ parameters }})
{% endif %}
RETURNS {{ return_type }}
{% if immutable %}
    IMMUTABLE
{% else -%}
   VOLATILE
{% endif %}
API_INTEGRATION = {{ api_integration }}
AS '{{ api_uri }}';
{%- endmacro -%}