{{ config(
    materialized='secret',
    meta={
        'type': 'GENERIC_STRING',
        'secret_string_variable': 'INTEGRATION_TEST_SECRET'
    }
) }}
