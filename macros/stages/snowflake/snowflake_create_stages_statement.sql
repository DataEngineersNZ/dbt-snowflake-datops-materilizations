{%- macro snowflake_create_or_replace_stage_statement(relation, sql) -%}

    {{ log("Creating stages " ~ relation) }}
CREATE OR REPLACE STAGE {{ relation.include(database=(not temporary), schema=(not temporary)) }}
    {{ sql }}
    ;

{%- endmacro -%}