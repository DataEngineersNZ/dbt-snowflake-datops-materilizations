{{ config(
    materialized='stored_procedure',
    meta={
        'preferred_language': 'sql',
        'parameters': 'input_val VARCHAR',
        'return_type': 'VARCHAR',
        'execute_as': 'caller'
    }
) }}

BEGIN
    RETURN input_val;
END;
