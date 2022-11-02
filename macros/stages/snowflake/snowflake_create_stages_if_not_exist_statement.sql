{%- macro snowflake_create_stages_if_not_exist_statement(relation, sql) -%}

    {{ log("Creating stages " ~ relation) }}
CREATE STAGE IF NOT EXISTS 

    {{ sql }}
    ;

{%- endmacro -%}