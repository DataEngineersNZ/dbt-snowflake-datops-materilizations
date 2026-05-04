{{ config(materialized='general_ddl') }}

CREATE SEQUENCE IF NOT EXISTS {{ target.database }}.{{ target.schema }}.test_integration_sequence
    START = 1
    INCREMENT = 1;
