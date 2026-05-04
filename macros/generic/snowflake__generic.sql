/*
  This materialization is used for creating any type of object.
  Use this as a last resort for DDL that isn't covered by other materializations.
*/
{%- materialization general_ddl, adapter='snowflake' -%}

    {%- set target_relation = this.incorporate(type='table') -%}

    {%- call statement('main') -%}
        {{ sql }};
    {%- endcall -%}

    {% do adapter.commit() %}

    {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}
