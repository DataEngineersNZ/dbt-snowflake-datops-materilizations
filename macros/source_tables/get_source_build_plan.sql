{% macro get_source_build_plan(source_node, is_first_run, object_type, allow_modify) %}
    {% if object_type == 'stream' %}
        {{ return(adapter.dispatch('get_stream_build_plan', 'dbt_dataengineers_materializations')(source_node)) }}
    {% elif object_type == 'external' %}
        {{ return(adapter.dispatch('get_external_build_plan', 'dbt_dataengineers_materializations')(source_node, is_first_run, allow_modify)) }}
    {% else %}
        {{ return(adapter.dispatch('get_source_build_plan', 'dbt_dataengineers_materializations')(source_node, is_first_run, allow_modify)) }}
    {% endif %}
{% endmacro %}

{% macro default__get_source_build_plan(source_node, is_first_run) %}
    {{ exceptions.raise_compiler_error("Staging sources is not implemented for the default adapter") }}
{% endmacro %}


{% macro default__get_stream_build_plan(source_node) %}
    {{ exceptions.raise_compiler_error("Staging steams is not implemented for the default adapter") }}
{% endmacro %}

{% macro default__get_external_build_plan(source_node) %}
    {{ exceptions.raise_compiler_error("Staging external sources is not implemented for the default adapter") }}
{% endmacro %}
