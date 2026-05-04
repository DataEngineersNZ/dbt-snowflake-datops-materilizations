-- Fails if the transient table does not exist or is not transient
SELECT 1
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ target.database }}.INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = '{{ target.schema }}'
      AND TABLE_NAME = 'TEST_IMMUTABLE_TABLE_TRANSIENT'
      AND TABLE_TYPE = 'BASE TABLE'
      AND IS_TRANSIENT = 'YES'
)
