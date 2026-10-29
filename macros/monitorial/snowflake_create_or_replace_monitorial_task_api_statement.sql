{%- macro snowflake_create_or_replace_monitorial_task_api_statement(target_relation,warehouse_name_or_size,schedule,message_type,severity,environment,display_message,prereq_statement,api_procedure,error_integration,sql) -%}

{{ log("Creating Alert as Task " ~ target_relation) }}
CREATE OR REPLACE TASK {{ target_relation.include(database=(not temporary), schema=(not temporary)) }}
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = '{{ warehouse_name_or_size }}'
    ERROR_INTEGRATION = '{{ error_integration }}'
    SCHEDULE = '{{ schedule }}'
    AS
        EXECUTE IMMEDIATE $$
{{ dbt_dataengineers_materializations.monitorial_pulse_notification_block(target_relation,message_type,severity,environment,display_message,prereq_statement,api_procedure,sql) }}
        $$;
{%- endmacro -%}