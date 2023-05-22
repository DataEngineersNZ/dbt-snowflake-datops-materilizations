{% macro snowflake_resume_monitorial_task_statement(target_relation) -%}
  {% call statement('resume_notification_serverless') -%}
    ALTER TASK {{ target_relation }} RESUME
  {%- endcall %}
{% endmacro %}
