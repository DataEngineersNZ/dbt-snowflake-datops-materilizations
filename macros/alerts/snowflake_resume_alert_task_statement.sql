{% macro snowflake_resume_alert_task_statement(target_relation) -%}
  {% call statement('resume_alert_task') -%}
    ALTER TASK {{ target_relation }} RESUME
  {%- endcall %}
{% endmacro %}
