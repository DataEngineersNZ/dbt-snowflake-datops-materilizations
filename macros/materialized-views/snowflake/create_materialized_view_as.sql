{% macro create_materialized_view_as(relation, sql, config) -%}
    {%- set secure = config.get('secure', default=false) -%}

    create or replace {% if secure -%} secure {%- endif %} materialized view {{relation}}
    as
        {{ sql }}
    ;

{% endmacro %}
