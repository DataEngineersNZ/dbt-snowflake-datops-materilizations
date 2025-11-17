{%- macro snowflake_create_fileformat_statement(create_or_replace, relation, sql) -%}

    {{ log("Creating fileformat " ~ relation) }}
{{ create_or_replace }} file format {{ relation.include(database=(not temporary), schema=(not temporary)) }}
    {{ sql }}
    ;

{%- endmacro -%}
