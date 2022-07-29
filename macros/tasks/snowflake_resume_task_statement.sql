{% macro snowflake_resume_task_statement(target_relation) -%}
  {% call statement('resume_task') -%}
    ALTER TASK {{ target_relation }} RESUME
  {%- endcall %}
{% endmacro %}
