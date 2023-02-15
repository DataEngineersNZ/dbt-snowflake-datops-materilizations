{%- macro snowflake_create_or_replace_alert_statement(relation, warehouse, schedule, action, sql) -%}

{{ log("Creating Alert " ~ relation) }}   
CREATE OR REPLACE ALERT {{ relation.include(database=(not temporary), schema=(not temporary)) }}
    WAREHOUSE = {{ warehouse }}
    SCHEDULE = '{{ schedule }}'
    IF( EXISTS(
        {{ sql }}
    ))
    THEN
        {{ action }}
    ;
{%- endmacro -%}