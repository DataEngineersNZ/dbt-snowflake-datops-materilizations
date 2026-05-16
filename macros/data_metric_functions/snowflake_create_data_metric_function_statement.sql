{%- macro snowflake_create_data_metric_function_statement(relation, is_secure, table_arguments, comment, statement) -%}

    {{ log("Creating Data Metric Function " ~ relation) }}
{% if is_secure %}
create or replace secure data metric function {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ table_arguments }})
{% else %}
create or replace data metric function {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ table_arguments }})
{% endif %}
returns NUMBER
language SQL
{% if comment %}
COMMENT = '{{ comment | replace("'", "''") }}'
{% endif %}
AS
$$
    {{ statement }}
$$
;

{%- endmacro -%}
