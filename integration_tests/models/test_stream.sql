-- depends_on: {{ ref('test_immutable_table') }}
{{ config(
    materialized='stream',
    meta={
        'source_model': 'test_immutable_table',
        'source_schema': target.schema
    }
) }}
