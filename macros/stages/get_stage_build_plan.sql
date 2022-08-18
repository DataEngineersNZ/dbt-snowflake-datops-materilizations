{% macro get_stage_build_plan(source_node) %}
    {{ return(adapter.dispatch('get_stage_build_plan', 'dbt_dataengineers_materilizations')(source_node)) }}
{% endmacro %}

{% macro default__get_stage_build_plan(source_node) %}
    {{ exceptions.raise_compiler_error("Staging stages is not implemented for the default adapter") }}
{% endmacro %}