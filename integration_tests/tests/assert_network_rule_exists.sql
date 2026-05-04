-- Fails if the network rule does not exist
{% call statement('show_network_rules', fetch_result=True) %}
    SHOW NETWORK RULES LIKE 'TEST_NETWORK_RULE' IN SCHEMA {{ target.database }}.{{ target.schema }}
{% endcall %}
{% set result = load_result('show_network_rules') %}

SELECT 1
WHERE {{ result.table | length }} = 0
