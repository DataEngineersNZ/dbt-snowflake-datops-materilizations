{#
    Compatibility wrapper for accessing custom config keys across dbt Core and dbt Fusion.

    In dbt Core, custom configs are set as top-level keys: config(enabled_targets=['prod'])
    In dbt Fusion, custom configs must be nested under meta: config(meta={'enabled_targets': ['prod']})

    These helpers check meta first (Fusion style), then fall back to top-level (Core style).
    This avoids dbt 1.11+ warnings about custom keys detected in meta.
#}

{% macro config_meta_get(key, default=none) %}
    {%- set meta = config.get("meta", none) -%}
    {%- if meta is not none and meta is mapping and key in meta -%}
        {{ return(meta[key]) }}
    {%- elif execute -%}
        {{ return(config.get(key, default)) }}
    {%- else -%}
        {{ return(default) }}
    {%- endif -%}
{% endmacro %}

{% macro config_meta_require(key) %}
    {%- set meta = config.get("meta", none) -%}
    {%- if meta is not none and meta is mapping and key in meta -%}
        {{ return(meta[key]) }}
    {%- elif execute -%}
        {%- set top_level_value = config.get(key, none) -%}
        {%- if top_level_value is not none -%}
            {{ return(top_level_value) }}
        {%- else -%}
            {% do exceptions.raise_compiler_error("Required configuration '" ~ key ~ "' was not found. Set it as a top-level config or under config.meta (required for dbt Fusion).") %}
        {%- endif -%}
    {%- else -%}
        {{ return(none) }}
    {%- endif -%}
{% endmacro %}
