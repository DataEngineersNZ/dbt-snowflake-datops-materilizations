-- Fails if the sequence created by the general_ddl materialization does not exist
SELECT 1
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ target.database }}.INFORMATION_SCHEMA.SEQUENCES
    WHERE SEQUENCE_SCHEMA = '{{ target.schema }}'
      AND SEQUENCE_NAME = 'TEST_INTEGRATION_SEQUENCE'
)
