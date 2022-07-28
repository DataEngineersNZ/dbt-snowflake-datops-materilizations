{%- macro snowflake_create_stages_statement(relation, sql) -%}

    {{ log("Creating stages " ~ relation) }}
CREATE OR REPLACE STAGE {{ relation.include(database=(not temporary), schema=(not temporary)) }}
    {{ sql }}
    ;

{%- endmacro -%}