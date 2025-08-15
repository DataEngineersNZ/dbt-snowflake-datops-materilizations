{% macro create_materialized_view_as(relation, sql, config) -%}
    {%- set secure = config.get('secure', default=false) -%}

    CREATE OR REPLACE
        {% if secure -%} SECURE {%- endif %}
        MATERIALIZED VIEW {{relation}}
    AS (
        {{sql}}
    );

{% endmacro %}
