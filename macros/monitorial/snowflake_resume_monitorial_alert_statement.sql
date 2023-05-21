{% macro snowflake_resume_monitorial_alert_statement(target_relation) -%}
  {% call statement('resume_notifictaion') -%}
    ALTER ALERT {{ target_relation }} RESUME
  {%- endcall %}
{% endmacro %}
