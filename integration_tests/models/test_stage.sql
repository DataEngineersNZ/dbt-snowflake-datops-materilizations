{{ config(materialized='stage') }}

    encryption = (type = 'SNOWFLAKE_SSE')
    comment = 'Integration test stage'
