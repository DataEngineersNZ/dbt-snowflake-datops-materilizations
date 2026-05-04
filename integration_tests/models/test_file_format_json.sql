{{ config(materialized='file_format', meta={'create_or_replace': true}) }}

    type = json
    null_if = ()
    compression = none
    ignore_utf8_errors = true
