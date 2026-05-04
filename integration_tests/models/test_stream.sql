{{ config(
    materialized='stream',
    meta={
        'source_model': 'test_source_table',
        'source_schema': target.schema
    }
) }}
