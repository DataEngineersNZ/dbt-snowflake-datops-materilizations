-- Fails if the Fusion-style config table is missing.
-- (The Core-style bare top-level custom key equivalent was removed: dbt Fusion
-- hard-rejects bare top-level custom config keys at parse time, so it can no
-- longer be exercised as a dual-engine test fixture. config_meta_get's
-- top-level fallback path remains for existing Core consumers who haven't
-- migrated to `meta`, but is no longer covered by a dedicated model here.)
SELECT 1
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ target.database }}.INFORMATION_SCHEMA.TABLES
    WHERE TABLE_SCHEMA = '{{ target.schema }}'
      AND TABLE_NAME = 'TEST_CONFIG_FUSION_STYLE'
      AND TABLE_TYPE = 'BASE TABLE'
)
