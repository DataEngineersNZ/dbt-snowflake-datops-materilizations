{% macro snowflake_resume_task_with_dependants_statement(target_relation) -%}
  {% call statement('resume_tasks') -%}
    select system$task_dependents_enable('{{ target_relation.include(database=(not temporary), schema=(not temporary)) }}');
  {%- endcall %}
{% endmacro %}


