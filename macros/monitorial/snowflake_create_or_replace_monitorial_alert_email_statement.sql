{%- macro snowflake_create_or_replace_monitorial_alert_email_statement(target_relation,warehouse_name_or_size,schedule,message_type,severity,environment,diplay_message,execute_immediate_statement,api_key,email_integration,notification_email,sql) -%}
{{ log("Creating EMail Based Alert " ~ target_relation) }}
CREATE OR REPLACE ALERT {{ target_relation.include(database=(not temporary), schema=(not temporary)) }}
    WAREHOUSE = {{ warehouse_name_or_size }}
    SCHEDULE = '{{ schedule }}'
    IF( EXISTS(
         SELECT CURRENT_TIMESTAMP() AS current_time
    ))
    THEN
        EXECUTE IMMEDIATE $$
            DECLARE
                alert_payload VARIANT;
                alert_subject VARCHAR DEFAULT (SELECT concat(current_account(), '~', '{{ api_key }}'));
                alert_version VARCHAR DEFAULT '1.0';
                alert_message_id VARCHAR DEFAULT (SELECT uuid_string());
                alert_message_type VARCHAR DEFAULT '{{ message_type }}';
                alert_description VARCHAR DEFAULT '{{ diplay_message }}';
                alert_timestamp TIMESTAMP DEFAULT (SELECT current_timestamp());
                alert_account_name VARCHAR DEFAULT (SELECT current_account());
                alert_name VARCHAR DEFAULT '{{ target_relation.include(database=(not temporary), schema=(not temporary)) }}';
                alert_severity VARCHAR DEFAULT '{{ severity }}';
                alert_environment VARCHAR DEFAULT '{{ environment }}';
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
                                                'environment', :alert_environment,
                                                'alertName', :alert_name,
                                                'severity', :alert_severity,
                                                'description', :alert_description,
                                                'messages', ARRAY_AGG(OBJECT_CONSTRUCT(*))) AS alert_body
                        FROM baseAlertQuery
                    )
                    SELECT alert_body INTO :alert_payload FROM arrayCreation;
                IF (:alert_payload != '') THEN
                    CALL SYSTEM$SEND_EMAIL(:alert_integration, :alert_email, :alert_subject, :error_alert_payload);
                    RETURN 'alert fired';
                ELSE
                    RETURN 'No alert fired';
                END IF;
            EXCEPTION
                WHEN  statement_error THEN
                    LET error_alert_payload VARCHAR := OBJECT_CONSTRUCT(
                                                'version', :alert_version,
                                                'messageId', :alert_message_id,
                                                'messageType', 'ALERT_STATEMENT_ERROR',
                                                'timestamp', :alert_timestamp,
                                                'accountName', :alert_account_name,
                                                'environment', :alert_environment,
                                                'alertName', :alert_name,
                                                'severity', 'ERROR',
                                                'description', :alert_description,
                                                'messages', ARRAY_CONSTRUCT(OBJECT_CONSTRUCT(
                                                    'Error type', 'Statement Error',
                                                    'Error Message', sqlerrm)));
                    CALL SYSTEM$SEND_EMAIL(:alert_integration, :alert_email, :alert_subject, :error_alert_payload);
                    RETURN 'error running alert';
                WHEN  expression_error THEN
                    LET error_alert_payload VARCHAR := OBJECT_CONSTRUCT(
                                                'version', :alert_version,
                                                'messageId', :alert_message_id,
                                                'messageType', 'ALERT_EXPRESSION_ERROR',
                                                'timestamp', :alert_timestamp,
                                                'accountName', :alert_account_name,
                                                'environment', :alert_environment,
                                                'alertName', :alert_name,
                                                'severity', 'ERROR',
                                                'description', :alert_description,
                                                'messages', ARRAY_CONSTRUCT(OBJECT_CONSTRUCT(
                                                    'Error type', 'expression Error',
                                                    'Error Message', sqlerrm,
                                                    'SQL Code', sqlcode,
                                                    'SQL State', sqlstate)));
                    CALL SYSTEM$SEND_EMAIL(:alert_integration, :alert_email, :alert_subject, :error_alert_payload);
                    RETURN 'error running alert';
        END;
        $$;
{%- endmacro -%}