{{ config(
    materialized='data_metric_function',
    meta={
        'table_arguments': 'arg_t TABLE(arg_c1 NUMBER, arg_c2 NUMBER)',
        'is_secure': false
    }
) }}

SELECT COUNT(*) FROM arg_t WHERE arg_c1 IS NULL OR arg_c2 IS NULL
