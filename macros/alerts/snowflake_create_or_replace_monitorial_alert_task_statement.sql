{%- macro snowflake_create_or_replace_monitorial_alert_task_statement(relation, warehouse, error_integration, schedule, severity, execute_immediate_statement, description, api_key, notification_email, notification_integration, sql) -%}

{{ log("Creating Alert as Task " ~ relation) }}
CREATE OR REPLACE TASK {{ relation.include(database=(not temporary), schema=(not temporary)) }}
    USER_TASK_MANAGED_INITIAL_WAREHOUSE_SIZE = '{{ warehouse }}'
    ERROR_INTEGRATION = '{{ error_integration }}'
    SCHEDULE = '{{ schedule }}'
    AS
        EXECUTE IMMEDIATE $$
            DECLARE
                alert_payload VARCHAR;
                alert_subject VARCHAR DEFAULT (SELECT concat(current_account(), '~', '{{ api_key }}'));
                alert_version VARCHAR DEFAULT '1.0';
                alert_message_id VARCHAR DEFAULT (SELECT uuid_string());
                alert_message_type VARCHAR DEFAULT 'USER_ALERT';
                alert_description VARCHAR DEFAULT '{{ description }}';
                alert_timestamp TIMESTAMP DEFAULT (SELECT current_timestamp());
                alert_account_name VARCHAR DEFAULT (SELECT current_account());
                alert_name VARCHAR DEFAULT '{{ relation.include(database=(not temporary), schema=(not temporary)) }}';
                alert_severity VARCHAR DEFAULT '{{ severity }}';
                alert_email VARCHAR DEFAULT '{{ notification_email }}';
                alert_integration VARCHAR DEFAULT '{{ notification_integration }}';
            BEGIN
                {% if execute_immediate_statement | length > 0 %}
                    EXECUTE IMMEDIATE '{{ execute_immediate_statement }}';
                {% endif %}
                WITH baseAlertQuery AS (
                       {{ sql }}
                ),
                arrayCreation AS (
                        SELECT OBJECT_CONSTRUCT('version', :alert_version,
                                                'messageId', :alert_message_id,
                                                'messageType', :alert_message_type,
                                                'timestamp', :alert_timestamp,
                                                'accountName', :alert_account_name,
                                                'alertName', :alert_name,
                                                'severity', :alert_severity,
                                                'description', :alert_description,
                                                'messages', ARRAY_AGG(OBJECT_CONSTRUCT(*))) AS alert_body
                        FROM baseAlertQuery
                    )
                    SELECT alert_body INTO :alert_payload FROM arrayCreation;
                IF (:alert_payload != '') THEN
                    CALL SYSTEM$SEND_EMAIL(:alert_integration, :alert_email, :alert_subject, :alert_payload);
                    RETURN 'alert fired';
                ELSE
                    RETURN 'No alert fired';
                END IF;
            END
        $$;
{%- endmacro -%}