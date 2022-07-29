{% macro snowflake_suspend_task_statement(target_relation) -%}
  {% call statement('suspend_task') -%}
    ALTER TASK {{ target_relation }} SUSPEND
  {%- endcall %}
{% endmacro %}