-- Fails if the stage does not exist
SELECT 1
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ target.database }}.INFORMATION_SCHEMA.STAGES
    WHERE STAGE_SCHEMA = '{{ target.schema }}'
      AND STAGE_NAME = 'TEST_STAGE'
)
