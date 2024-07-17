{%- macro snowflake_create_sql_user_defined_functions_statement(relation, is_secure,  immutable, parameters, return_type, memoizable, statement) -%}

{% if is_secure  %}
create or replace secure function {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ parameters }})
{% else %}
create or replace function {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ parameters }})
{% endif %}
       returns {{ return_type }}
       --[ [ NOT ] NULL ]
{% if immutable %}
       immutable
{% else %}
       volatile
{%- endif %}
{% if memoizable %}
       memoizable
{%- endif %}
AS
$$
 {{ statement }}
$$
;
{%- endmacro -%}
