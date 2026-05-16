/*
  This materialization is used for creating Data Metric Function (DMF) objects.
  The idea behind this materialization is for ability to define create data metric function statements and have dbt use the necessary logic
  of deploying the data metric function in a consistent manner and logic.

  Snowflake DMFs are used for data quality monitoring. They accept one or more TABLE arguments
  and return a NUMBER result. The model body provides the SQL expression.
*/
{%- materialization data_metric_function, adapter='snowflake' -%}
  {%- set table_arguments = dbt_dataengineers_materializations.config_meta_require('table_arguments') -%}
  {%- set is_secure = dbt_dataengineers_materializations.config_meta_get('is_secure', false) -%}
  {%- set comment = dbt_dataengineers_materializations.config_meta_get('comment', none) -%}
  {%- set identifier = dbt_dataengineers_materializations.config_meta_get('override_name', model['alias'] ) -%}

  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- BEGIN happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

      --------------------------------------------------------------------------------------------------------------------
  -- build model

  {% call statement('main') -%}
    {{ dbt_dataengineers_materializations.snowflake_create_data_metric_function_statement(target_relation, is_secure, table_arguments, comment, sql) }}
  {%- endcall %}

      --------------------------------------------------------------------------------------------------------------------
  -- build model
  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}
  {{ run_hooks(post_hooks, inside_transaction=False) }}

  -- return
  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}
