-- Fails if the JSON file format does not exist
SELECT 1
WHERE NOT EXISTS (
    SELECT 1
    FROM {{ target.database }}.INFORMATION_SCHEMA.FILE_FORMATS
    WHERE FILE_FORMAT_SCHEMA = '{{ target.schema }}'
      AND FILE_FORMAT_NAME = 'TEST_FILE_FORMAT_JSON'
)
