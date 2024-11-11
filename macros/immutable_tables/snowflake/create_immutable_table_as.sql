{% macro create_immutable_table_as(relation, sql) -%}

CREATE TABLE IF NOT EXISTS {{ relation.include(database=(not temporary), schema=(not temporary)) }} AS (
    {{ sql }}
);

{% endmacro %}