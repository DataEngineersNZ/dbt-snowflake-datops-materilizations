-- Fails if the stored procedure does not exist
SELECT 1
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ target.database }}.INFORMATION_SCHEMA.PROCEDURES
    WHERE PROCEDURE_SCHEMA = '{{ target.schema }}'
      AND PROCEDURE_NAME = 'TEST_STORED_PROCEDURE_SQL'
)
