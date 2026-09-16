-- Fails if the monitorial alert does not exist
{% call statement('show_monitorial_alerts', fetch_result=True) %}
    SHOW ALERTS LIKE 'TEST_MONITORIAL' IN SCHEMA {{ target.database }}.{{ target.schema }}
{% endcall %}
{% set result = load_result('show_monitorial_alerts') %}

SELECT 1
WHERE {{ result.table | length }} = 0
