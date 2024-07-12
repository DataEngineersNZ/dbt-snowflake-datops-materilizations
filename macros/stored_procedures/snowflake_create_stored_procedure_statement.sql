{%- macro snowflake_create_stored_procedure_statement(relation, preferred_language, parameters, return_type, execute_as, sql) -%}

    {{ log("Creating Stored Procedure " ~ relation) }}   
CREATE OR REPLACE PROCEDURE {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ parameters }})
returns {{ return_type }}
language {{ preferred_language }}
execute as {{ execute_as }}
AS
$$
    {{ sql }}
$$
;

{%- endmacro -%}