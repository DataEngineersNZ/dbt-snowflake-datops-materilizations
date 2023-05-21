/*
  This materialization is used for creating an alert objects.
  The idea behind this materialization is for ability to define CREATE OR REPLACE ALERT statements and have dbt use the necessary logic
  of deploying the alert in a consistent manner and logic.
*/

{%- materialization alert, adapter='snowflake' -%}
  {%- set warehouse_size = config.get('warehouse_size', default='alert_wh') -%}
  {%- set schedule = config.get('schedule', default='60 MINUTE') -%}
  {%- set action = config.get('action', default=none) -%}
  {%- set identifier = model['alias'] -%}
  {%- set enabled_targets = config.get('enabled_targets', [target.name]) %}
  {%- set is_enabled = target.name in enabled_targets -%}

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- BEGIN happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}
  {% call statement('main') -%}}
    {{ dbt_dataengineers_materializations.snowflake_create_or_replace_alert_statement(target_relation, warehouse_size, schedule, action, sql) }}
  {%- endcall %}
  {%- if is_enabled == false %}
    {% if is_serverless == false %}
      {{ dbt_dataengineers_materializations.snowflake_suspend_alert_statement(target_relation) }}
    {% else %}
      {{ dbt_dataengineers_materializations.snowflake_suspend_alert_task_statement(target_relation) }}
    {% endif %}
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
