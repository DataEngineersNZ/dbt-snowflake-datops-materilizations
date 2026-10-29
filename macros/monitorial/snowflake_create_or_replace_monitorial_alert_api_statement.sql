{%- macro snowflake_create_or_replace_monitorial_alert_api_statement(target_relation,warehouse_name_or_size,schedule,message_type,severity,environment,display_message,prereq_statement,api_procedure,sql) -%}
{{ log("Creating API Based Alert " ~ target_relation) }}
CREATE OR REPLACE ALERT {{ target_relation.include(database=(not temporary), schema=(not temporary)) }}
    WAREHOUSE = {{ warehouse_name_or_size }}
    SCHEDULE = '{{ schedule }}'
    IF( EXISTS(
         SELECT CURRENT_TIMESTAMP() AS current_time
    ))
    THEN
        EXECUTE IMMEDIATE $$
{{ dbt_dataengineers_materializations.monitorial_pulse_notification_block(target_relation,message_type,severity,environment,display_message,prereq_statement,api_procedure,sql) }};
        $$;
{%- endmacro -%}