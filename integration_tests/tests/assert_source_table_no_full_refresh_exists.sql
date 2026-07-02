-- Fails if the source table with disable_full_refresh was not created
SELECT 1
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ target.database }}.INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = '{{ target.schema }}'
      AND TABLE_NAME = 'TEST_SOURCE_TABLE_NO_FULL_REFRESH'
      AND TABLE_TYPE = 'BASE TABLE'
)
