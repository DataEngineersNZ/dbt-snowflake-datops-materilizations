-- Fails if the alert does not exist
{% call statement('show_alerts', fetch_result=True) %}
    SHOW ALERTS LIKE 'TEST_ALERT' IN SCHEMA {{ target.database }}.{{ target.schema }}
{% endcall %}
{% set result = load_result('show_alerts') %}

SELECT 1
WHERE {{ result.table | length }} = 0
