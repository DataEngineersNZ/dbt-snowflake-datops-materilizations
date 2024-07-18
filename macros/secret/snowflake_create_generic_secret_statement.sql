{%- macro snowflake_create_generic_secret_statement(target_relation, secret_string) -%}
create secret if not exists {{ target_relation.include(database=(not temporary), schema=(not temporary)) }}
type = GENERIC_STRING
secret_string = '{{ secret_string }}';
{%- endmacro -%}