{%- macro snowflake_create_python_user_defined_functions_statement(relation, is_secure,  immutable, parameters, return_type, null_input_behavior, statement) -%}

{% if is_secure  %}
create or replace secure function {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ parameters }})
{% else %}
create or replace function {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ parameters }})
{% endif %}
       returns {{ return_type }}
	language javascript
       {{ null_input_behavior }}
{% if immutable %}
       immutable
{% else %}
       volatile
{%- endif -%}
AS
'
 {{ statement }}
'
;
{%- endmacro -%}
