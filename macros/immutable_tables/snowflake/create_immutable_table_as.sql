{% macro create_immutable_table_as(relation, sql) -%}

create table if not exists {{ relation.include(database=(not temporary), schema=(not temporary)) }} as (
    {{ sql }}
);

{% endmacro %}