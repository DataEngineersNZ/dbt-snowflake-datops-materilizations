{{ config(
    materialized='user_defined_function',
    meta={
        'preferred_language': 'javascript',
        'return_type': 'FLOAT',
        'parameters': 'x FLOAT, y FLOAT',
        'null_input_behavior': 'CALLED ON NULL INPUT'
    }
) }}

return X + Y;
