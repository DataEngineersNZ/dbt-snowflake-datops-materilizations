{% macro create_materialized_view_as(relation, sql, config) -%}
    {%- set secure = config.get('secure', default=false) -%}
    {%- set cluster_by_keys = config.get('cluster_by', default=none) -%}
    {%- set enable_automatic_clustering = config.get('automatic_clustering', default=false) -%}

    {%- if cluster_by_keys is not none and cluster_by_keys is string -%}
        {%- set cluster_by_keys = [cluster_by_keys] -%}
    {%- endif -%}
    {%- if cluster_by_keys is not none -%}
        {%- set cluster_by_string = cluster_by_keys|join(", ")-%}
    {% else %}
        {%- set cluster_by_string = none -%}
    {%- endif -%}

    CREATE OR REPLACE
        {% if secure -%} SECURE {%- endif %} 
        MATERIALIZED VIEW {{relation}}
    AS (
        {{sql}}
    );
    
    {% if cluster_by_string is not none and not temporary -%}
        ALTER MATERIALIZED VIEW {{relation}} CLUSTER BY ({{cluster_by_string}});
    {%- endif -%}
    {% if enable_automatic_clustering and cluster_by_string is not none and not temporary  -%}
        ALTER MATERIALIZED VIEW {{relation}} RESUME RECLUSTER;
    {%- endif -%}

{% endmacro %}
