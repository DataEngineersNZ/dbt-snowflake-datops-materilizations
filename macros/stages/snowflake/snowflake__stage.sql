/*
  This materialization is used for creating stage objects.
  The idea behind this materialization is for ability to define CREATE STAGE statements and have dbt use the necessary logic
  of deploying the stage in a consistent manner and logic.
  Adapted from https://github.com/venkatra/dbt_hacks

*/
{%- materialization stage, adapter='snowflake' -%}
    {%- set full_refresh_mode = (flags.FULL_REFRESH == True) -%}
    {%- set identifier = model['alias'] -%}
    {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}

    --------------------------------------------------------------------------------------------------------------------

    -- setup
    {{ run_hooks(pre_hooks, inside_transaction=False) }}

    -- `BEGIN` happens here:
    {{ run_hooks(pre_hooks, inside_transaction=True) }}


    --------------------------------------------------------------------------------------------------------------------

    -- build model
    {%- call statement('main') -%}
      {{ dbt_dataengineers_materilizations.snowflake_create_stages_if_not_exist_statement(target_relation, sql) }}
    {%- endcall -%}

   --------------------------------------------------------------------------------------------------------------------
    {{ run_hooks(post_hooks, inside_transaction=True) }}
    -- `COMMIT` happens here
    {{ adapter.commit() }}

    {{ run_hooks(post_hooks, inside_transaction=False) }}

    -- return
    {{ return({'relations': [target_relation]}) }}

{%- endmaterialization %}
