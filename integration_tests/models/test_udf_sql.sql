{{ config(
    materialized='user_defined_function',
    meta={
        'preferred_language': 'SQL',
        'return_type': 'FLOAT',
        'parameters': 'x FLOAT, y FLOAT',
        'immutable': true
    }
) }}

SELECT x + y
