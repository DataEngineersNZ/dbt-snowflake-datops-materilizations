{% macro apply_clusters(relation, config) -%}
    {%- set cluster_by_keys = config.get('cluster_by', default=none) -%}

    {%- if cluster_by_keys is not none and cluster_by_keys is string -%}
        {%- set cluster_by_keys = [cluster_by_keys] -%}
    {%- endif -%}
    {%- if cluster_by_keys is not none -%}
        {%- set cluster_by_string = cluster_by_keys|join(", ")-%}
    {% else %}
        {%- set cluster_by_string = none -%}
    {%- endif -%}

    {% if cluster_by_string is not none -%}
        alter materialized view {{relation}} cluster by ({{cluster_by_string}});
    {%- endif -%}

{% endmacro %}
