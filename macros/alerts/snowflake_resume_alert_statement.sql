{% macro snowflake_resume_alert_statement(target_relation) -%}
  {% call statement('resume_alert') -%}
    ALTER ALERT {{ target_relation }} RESUME
  {%- endcall %}
{% endmacro %}
