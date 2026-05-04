{{ config(
    materialized='network_rule',
    meta={
        'rule_type': 'HOST_PORT',
        'mode': 'EGRESS',
        'value_list': ['example.com', 'test.example.com:443']
    }
) }}
