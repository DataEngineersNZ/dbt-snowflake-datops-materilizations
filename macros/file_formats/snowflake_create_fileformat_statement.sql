{%- macro snowflake_create_fileformat_statement(relation, sql) -%}

    {{ log("Creating fileformat " ~ relation) }}
CREATE OR REPLACE FILE FORMAT {{ relation.include(database=(not temporary), schema=(not temporary)) }}
    {{ sql }}
    ;

{%- endmacro -%}

