/*
  This materialization is used for creating any type of object
  The idea behind this materialization is for ability to define a DDL statement that needs to be executed but isn't current
  available based on its own materialisation.
  This should be used as a last resort.
  Adapted from https://github.com/venkatra/dbt_hacks

*/
{%- materialization generic, adapter='snowflake' -%}
    --------------------------------------------------------------------------------------------------------------------

    -- setup
    {{ run_hooks(pre_hooks, inside_transaction=False) }}

    -- `BEGIN` happens here:
    {{ run_hooks(pre_hooks, inside_transaction=True) }}

    --------------------------------------------------------------------------------------------------------------------

    -- build model
    {%- call statement('main') -%}
      {{ dbt_dataengineers_materilizations.snowflake_generic_statement(sql) }}
    {%- endcall -%}

   --------------------------------------------------------------------------------------------------------------------
    {{ run_hooks(post_hooks, inside_transaction=True) }}

    -- `COMMIT` happens here
    {{ adapter.commit() }}

    {{ run_hooks(post_hooks, inside_transaction=False) }}

    -- return
    {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}
