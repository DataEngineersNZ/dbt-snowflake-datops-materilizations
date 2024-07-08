{%- macro snowflake_create_password_secret_statement(target_relation, username, password) -%}
create secret if not exists {{ target_relation.include(database=(not temporary), schema=(not temporary)) }}
type = PASSWORD
username = '{{ username }}'
password = '{{ password }}';
{%- endmacro -%}