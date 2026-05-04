-- Fails if the secret does not exist
-- Secrets are not in INFORMATION_SCHEMA, use SHOW SECRETS
{% call statement('show_secrets', fetch_result=True) %}
    SHOW SECRETS LIKE 'TEST_SECRET' IN SCHEMA {{ target.database }}.{{ target.schema }}
{% endcall %}
{% set result = load_result('show_secrets') %}

SELECT 1
WHERE {{ result.table | length }} = 0
