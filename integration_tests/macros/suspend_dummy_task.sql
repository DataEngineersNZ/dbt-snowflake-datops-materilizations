{% macro suspend_dummy_task() %}
  {#-- Resets dummy_task (owned by the dummy_package test dependency, not this project) back to
       suspended after its own creation materialization auto-resumed it. Run this immediately
       before `enable_tasks` in CI so assert_dummy_task_not_resumed.sql can prove enable_tasks'
       package/selection scoping correctly excludes it instead of resuming it again. --#}
  {% if execute %}
    {% set relation = api.Relation.create(database=target.database, schema=target.schema, identifier='dummy_task') %}
    {% do run_query('ALTER TASK ' ~ relation ~ ' SUSPEND') %}
    {{ log('Suspended dummy_task ahead of enable_tasks scoping test', info=True) }}
  {% endif %}
{% endmacro %}
