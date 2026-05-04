{% macro create_materialized_view_as(relation, sql, config) -%}
    {%- set secure = dbt_dataengineers_materializations.config_meta_get('secure', false) -%}

    create or replace {% if secure -%} secure {%- endif %} materialized view {{relation}}
    as
        {{ sql }}
    ;

{% endmacro %}
