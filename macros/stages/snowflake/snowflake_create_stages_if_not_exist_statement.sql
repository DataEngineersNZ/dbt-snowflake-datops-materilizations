{%- macro snowflake_create_stages_if_not_exist_statement(relation, sql) -%}

    {{ log("Creating stages " ~ relation) }}
CREATE STAGE IF NOT EXISTS {{ relation.include(database=(not temporary), schema=(not temporary)) }}
    {{ sql }}
    ;

{%- endmacro -%}