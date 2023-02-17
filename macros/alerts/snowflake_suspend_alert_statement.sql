{% macro snowflake_suspend_alert_statement(target_relation) -%}
  {% call statement('suspend_alert') -%}
    ALTER ALERT {{ target_relation }} SUSPEND
  {%- endcall %}
{% endmacro %}