-- Fails if the stream does not exist
-- Note: Streams are not in INFORMATION_SCHEMA, use SHOW STREAMS
{% call statement('show_streams', fetch_result=True) %}
    SHOW STREAMS LIKE 'TEST_STREAM' IN SCHEMA {{ target.database }}.{{ target.schema }}
{% endcall %}
{% set result = load_result('show_streams') %}

SELECT 1
WHERE {{ result.table | length }} = 0
