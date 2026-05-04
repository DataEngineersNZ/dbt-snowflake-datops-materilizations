-- Fails if the immutable table does not exist
SELECT 1
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ target.database }}.INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = '{{ target.schema }}'
      AND TABLE_NAME = 'TEST_IMMUTABLE_TABLE'
      AND TABLE_TYPE = 'BASE TABLE'
)
