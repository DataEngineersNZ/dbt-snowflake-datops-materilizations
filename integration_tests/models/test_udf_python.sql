{{ config(
    materialized='user_defined_function',
    meta={
        'preferred_language': 'python',
        'runtime_version': '3.11',
        'handler_name': 'add_numbers',
        'return_type': 'FLOAT',
        'parameters': 'x FLOAT, y FLOAT'
    }
) }}

def add_numbers(x, y):
    return x + y
