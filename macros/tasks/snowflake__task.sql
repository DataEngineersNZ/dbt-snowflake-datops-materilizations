{%- materialization task, adapter='snowflake' -%}

  {%- set warehouse_name_or_size = config.get('warehouse_name_or_size') -%}
  {%- set is_serverless = config.get('is_serverless', default=true) -%}
  {%- set task_schedule = config.get('schedule') -%}
  {%- set task_after = config.get('task_after') -%}
  {%- set stream_name = config.get('stream_name') -%}

  {% set target_relation = this %}
  {% set existing_relation = load_relation(this) %}

  {%- set stream_relation = api.Relation.create( identifier=stream_name, schema=schema, database=database) -%}  

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  {% set build_sql = snowflake_create_task_statement(target_relation, is_serverless, warehouse_name_or_size, task_schedule, task_after, stream_relation, sql) %}

  {%- call statement('main') -%}
    {{ build_sql }}
  {%- endcall -%}

  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}