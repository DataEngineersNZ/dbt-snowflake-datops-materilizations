{{ config(materialized='stage', meta={'create_or_replace': true}) }}

    encryption = (type = 'SNOWFLAKE_SSE')
    comment = 'Integration test stage - create or replace'
