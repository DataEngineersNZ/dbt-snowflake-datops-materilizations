{%- macro snowflake_create_python_user_defined_functions_statement(relation, is_secure,  immutable, parameters, return_type, runtime_version, packages, external_access_integrations, secrets, handler_name, imports, null_input_behavior, statement) -%}

{% if is_secure  %}
create or replace secure function {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ parameters }})
{% else %}
create or replace function {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ parameters }})
{% endif %}
       returns {{ return_type }}
       language PYTHON
       {{ null_input_behavior }}
{% if immutable %}
       immutable
{% else %}
       volatile
{%- endif -%}
       runtime_version = '{{ runtime_version }}'
{% if imports is not none -%}
	imports = ('{{ imports|join('\', \'') }}')
{%- endif -%}
{% if packages is not none -%}
       packages = ('{{ packages|join('\', \'') }}')
{%- endif -%}
	handler = '{{ handler_name }}'
{% if external_access_integrations is not none -%}
	external_access_integrations = ({{ external_access_integrations|join(', ') }})
{%- endif -%}
{% if secrets is not none -%}
	secrets = ('{{ secrets|join(', ') }}')
{%- endif -%}
AS

'
 {{ statement }}
'
;
{%- endmacro -%}
