-- Fails if the SQL UDF does not exist
SELECT 1
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ target.database }}.INFORMATION_SCHEMA.FUNCTIONS
    WHERE FUNCTION_SCHEMA = '{{ target.schema }}'
      AND FUNCTION_NAME = 'TEST_UDF_SQL'
)
