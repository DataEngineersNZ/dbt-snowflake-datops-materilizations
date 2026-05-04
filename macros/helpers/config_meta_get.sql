{#
    Compatibility wrapper for accessing custom config keys across dbt Core and dbt Fusion.

    In dbt Core, custom configs are set as top-level keys: config(enabled_targets=['prod'])
    In dbt Fusion, custom configs must be nested under meta: config(meta={'enabled_targets': ['prod']})

    These helpers check both locations, allowing the package to work on both engines.
#}

{% macro config_meta_get(key, default=none) %}
    {%- set top_level_value = config.get(key, none) -%}
    {%- if top_level_value is not none -%}
        {{ return(top_level_value) }}
    {%- else -%}
        {%- set meta = config.get("meta", {}) -%}
        {%- if meta is not none and meta is mapping and key in meta -%}
            {{ return(meta[key]) }}
        {%- else -%}
            {{ return(default) }}
        {%- endif -%}
    {%- endif -%}
{% endmacro %}

{% macro config_meta_require(key) %}
    {%- set top_level_value = config.get(key, none) -%}
    {%- if top_level_value is not none -%}
        {{ return(top_level_value) }}
    {%- else -%}
        {%- set meta = config.get("meta", {}) -%}
        {%- if meta is not none and meta is mapping and key in meta -%}
            {{ return(meta[key]) }}
        {%- else -%}
            {% do exceptions.raise_compiler_error("Required configuration '" ~ key ~ "' was not found. Set it as a top-level config or under config.meta (required for dbt Fusion).") %}
        {%- endif -%}
    {%- endif -%}
{% endmacro %}
