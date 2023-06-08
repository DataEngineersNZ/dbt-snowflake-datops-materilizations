/*
      This materialization is used for creating task objects.
      The idea behind this materialization is for ability to define tasks ddl and have dbt use the necessary logic
      of deploying the task in a consistent manner and logic.
*/

{%- materialization task, adapter='snowflake' -%}

  {%- set warehouse_name_or_size = config.get('warehouse_name_or_size', default='xsmall') -%}
  {%- set is_serverless = config.get('is_serverless', default=true) -%}
  {%- set task_schedule = config.get('schedule') -%}
  {%- set task_after = config.get('task_after') -%}
  {%- set stream_name = config.get('stream_name') -%}
  {%- set error_integration = config.get('error_integration', default=var('default_monitorial_error_integration', '')) -%}

  {%- set enabled_targets = config.get('enabled_targets', [target.name]) %}
  {%- set is_enabled = target.name in enabled_targets -%}

  {% set target_relation = this %}
  {% set existing_relation = load_relation(this) %}

  {% if stream_name %}
    {% set stream_relation = api.Relation.create( identifier=stream_name, schema=schema, database=database) %}
  {% else %}
    {% set stream_name = none %}
  {% endif %}

  {% if task_after %}
    {% set task_after_relation = api.Relation.create(database=database, schema=schema, identifier=task_after) %}
  {% else %}
    {% set task_after_relation = none %}
  {% endif %}
  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}


  {% if task_after %}
    -- First, suspend the top parent task if there is one
    {% set top_parent = dbt_dataengineers_materializations.snowflake_get_task_top_parent_node(model) %}
    {% if top_parent %}
      {% set top_parent_relation = api.Relation.create(database=top_parent.database, schema=top_parent.schema, identifier=top_parent.name) %}
      {{ log('suspending '~ top_parent_relation, info=True) }}
      {% do dbt_dataengineers_materializations.snowflake_suspend_task_statement(top_parent_relation) %}
    {% endif %}
  {% endif %}

  {% set build_sql = dbt_dataengineers_materializations.snowflake_create_task_statement(target_relation, is_serverless, warehouse_name_or_size, task_schedule, task_after_relation, stream_relation, error_integration, sql) %}

  {%- call statement('main') -%}
    {{ build_sql }}
  {%- endcall -%}

  -- Third, resume the new task and the top parent task --
  {% if is_enabled %}
    {{ log('resuming '~ target_relation, info=True) }}
    {% do dbt_dataengineers_materializations.snowflake_resume_task_statement(target_relation) %}
  {% endif %}
  {% if top_parent %}
    {% if target.name in top_parent.config.enabled_targets %}
      {{ log('resuming '~ top_parent_relation, info=True) }}
      {% do dbt_dataengineers_materializations.snowflake_resume_task_statement(top_parent_relation) %}
    {% endif %}
  {% endif %}


  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}