{%- macro snowflake_create_fileformat_statement(relation, sql, create_or_replace="CREATE FILE FORMAT IF NOT EXISTS") -%}

    {{ log("Creating fileformat " ~ relation) }}
{{ create_or_replace }} {{ relation.include(database=(not temporary), schema=(not temporary)) }}
    {{ sql }}
    ;

{%- endmacro -%}
