{{ config(materialized='file_format', meta={'create_or_replace': true}) }}

    type = csv
    field_delimiter = ','
    skip_header = 1
    field_optionally_enclosed_by = '"'
