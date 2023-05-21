{% macro snowflake_suspend_monitorial_task_statement(target_relation) -%}
  {% call statement('suspend_notification_serverless') -%}
    ALTER TASK {{ target_relation }} SUSPEND
  {%- endcall %}
{% endmacro %}