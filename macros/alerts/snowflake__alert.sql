/*
  This materialization is used for creating an alert objects.
  The idea behind this materialization is for ability to define CREATE OR REPLACE ALERT statements and have dbt use the necessary logic
  of deploying the alert in a consistent manner and logic.
*/

{%- materialization alert, adapter='snowflake' -%}
  {%- set warehouse = config.get('warehouse', default='task_wh') -%}
  {%- set schedule = config.get('schedule', default='60 MINUTE') -%}
  {%- set action = config.get('action', default='snowwatch' ) -%}
  {%- set severity = config.get('severity', default='error' ) -%}

  {%- if target.name == 'prod' -%}
    {%- set is_enabled = config.get('is_enabled_prod', default=true) -%}
  {%- elif target.name == 'test' -%}
    {%- set is_enabled = config.get('is_enabled_test', default=false) -%}
  {%- else -%}
    {%- set is_enabled = config.get('is_enabled_dev', default=false) -%}
  {%- endif -%}

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- BEGIN happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

      --------------------------------------------------------------------------------------------------------------------

  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}
  {% call statement('main') -%}
    {{ dbt_dataengineers_materilizations.snowflake_create_or_replace_alert_statement(target_relation, warehouse, schedule, severity, action, sql) }}
  {%- endcall %}
  {%- if is_enabled == false %}
      {{ dbt_dataengineers_materilizations.snowflake_suspend_alert_statement(target_relation) }}
  {% endif %}

      --------------------------------------------------------------------------------------------------------------------
  -- build model
  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}
  {{ run_hooks(post_hooks, inside_transaction=False) }}

  -- return
  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}
