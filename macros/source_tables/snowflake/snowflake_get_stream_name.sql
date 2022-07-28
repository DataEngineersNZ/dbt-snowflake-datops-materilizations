{% macro snowflake_get_stream_name(model_name) -%}
    {{ return('stm_' + model_name) }}
{%- endmacro %}
