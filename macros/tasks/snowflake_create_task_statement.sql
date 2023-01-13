{% macro snowflake_create_task_statement(target_relation, is_serverless, warehouse_name_or_size, task_schedule, task_after_relation, stream_relation, error_integration, sql) -%}
    CREATE OR REPLACE TASK  {{ target_relation.include(database=(not temporary), schema=(not temporary)) }} 
      {% if is_serverless %}
        USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = '{{ warehouse_name_or_size }}'
      {% else %}
        WAREHOUSE = '{{ warehouse_name_or_size }}'
      {% endif %}
      {% if task_after_relation %}
        AFTER {{ task_after_relation.include(database=(not temporary), schema=(not temporary)) }}
      {% else %}
        SCHEDULE = '{{ task_schedule }}'
      {% endif %}
      {% if error_integration != '' %}
        ERROR_INTEGRATION = '{{ error_integration }}'
      {% endif %}
      {% if stream_relation %}
        WHEN SYSTEM$STREAM_HAS_DATA('{{ stream_relation.include(database=(not temporary), schema=(not temporary)) }}')
      {% endif %}
    AS
        {{ sql }}
{%- endmacro %}
