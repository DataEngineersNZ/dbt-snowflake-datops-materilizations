{% macro snowflake_suspend_alert_statement(target_relation) -%}
  {% call statement('suspend_alert_task') -%}
    ALTER TASK {{ target_relation }} SUSPEND
  {%- endcall %}
{% endmacro %}