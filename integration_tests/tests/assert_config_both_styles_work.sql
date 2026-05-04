-- Fails if either the Fusion-style or Core-style config table is missing
-- Both should create identical immutable tables
SELECT 1
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ target.database }}.INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = '{{ target.schema }}'
      AND TABLE_NAME = 'TEST_CONFIG_FUSION_STYLE'
      AND TABLE_TYPE = 'BASE TABLE'
)
OR NOT EXISTS (
    SELECT 1
    FROM {{ target.database }}.INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = '{{ target.schema }}'
      AND TABLE_NAME = 'TEST_CONFIG_CORE_STYLE'
      AND TABLE_TYPE = 'BASE TABLE'
)
