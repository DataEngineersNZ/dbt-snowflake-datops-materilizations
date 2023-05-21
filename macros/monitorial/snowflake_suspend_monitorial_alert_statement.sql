{% macro snowflake_suspend_monitorial_alert_statement(target_relation) -%}
  {% call statement('suspend_notification') -%}
    ALTER ALERT {{ target_relation }} SUSPEND
  {%- endcall %}
{% endmacro %}