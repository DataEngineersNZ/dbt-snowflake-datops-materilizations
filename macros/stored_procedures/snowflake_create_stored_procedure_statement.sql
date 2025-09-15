{%- macro snowflake_create_stored_procedure_statement(relation, copy_grants_statement, preferred_language, parameters, return_type, execute_as, sql) -%}

    {{ log("Creating Stored Procedure " ~ relation) }}
create or replace procedure {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ parameters }})
{{ copy_grants_statement }}
returns {{ return_type }}
language {{ preferred_language }}
execute as {{ execute_as }}
AS
$$
    {{ sql }}
$$
;

{%- endmacro -%}