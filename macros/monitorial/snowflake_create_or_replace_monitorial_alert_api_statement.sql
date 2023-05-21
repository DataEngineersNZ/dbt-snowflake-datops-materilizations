{%- macro snowflake_create_or_replace_monitorial_alert_api_statement(target_relation,warehouse_name_or_size,schedule,message_type,severity,environment,diplay_message,prereq_statement,api_key,api_function,sql) -%}
{{ log("Creating API Based Alert " ~ target_relation) }}
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
                alert_email VARCHAR DEFAULT '{{ notification_email }}';
                alert_integration VARCHAR DEFAULT '{{ email_integration }}';
                alert_environment VARCHAR DEFAULT '{{ environment }}';
                alter_payload_received VARCHAR DEFAULT '';
            BEGIN
                {% if prereq_statement | length > 0 %}
                    {{ prereq_statement }};
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
                    SELECT {{ api_function }}(:alert_account_name,:alert_name,:alert_environment,:alert_message_type,:alert_severity,:alert_description,:alert_payload)
                    INTO :alter_payload_received;
                    RETURN :alert_payload_received;
                ELSE
                    RETURN 'No notification fired';
                END IF;
            END;
        $$;
{%- endmacro -%}