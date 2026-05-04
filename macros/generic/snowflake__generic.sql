/*
  This materialization is used for creating any type of object
  The idea behind this materialization is for ability to define a DDL statement that needs to be executed but isn't current
  available based on its own materialisation.
  This should be used as a last resort.
  Adapted from https://github.com/venkatra/dbt_hacks

*/
{%- materialization generic, adapter='snowflake' -%}

    {% set target_relation = api.Relation.create(database=database, schema=schema, identifier=model['alias']) %}

    {{ run_hooks(pre_hooks) }}

    {%- call statement('main') -%}
      {{ dbt_dataengineers_materializations.snowflake_generic_statement(sql) }}
    {%- endcall -%}

    {{ run_hooks(post_hooks) }}

    {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}
