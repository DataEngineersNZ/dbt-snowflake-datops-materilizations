{%- macro snowflake_create_or_replace_monitorial_alert_api_statement(target_relation,warehouse_name_or_size,schedule,message_type,severity,environment,display_message,prereq_statement,api_function,sql) -%}
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
                alert_message_type VARCHAR DEFAULT '{{ message_type }}';
                alert_display_message VARCHAR DEFAULT '{{ display_message }}';
                alert_account_name VARCHAR DEFAULT (SELECT current_account());
                alert_name VARCHAR DEFAULT '{{ target_relation.include(database=(not temporary), schema=(not temporary)) }}';
                alert_severity VARCHAR DEFAULT '{{ severity }}';
                alert_environment VARCHAR DEFAULT '{{ environment }}';
                alert_payload_recieved VARCHAR DEFAULT '';
            BEGIN
                {% if prereq_statement | length > 0 %}
                    {{ prereq_statement }};
                {% endif %}
                WITH baseAlertQuery AS (
                       {{ sql }}
                ),
                arrayCreation AS (
                        SELECT ARRAY_AGG(OBJECT_CONSTRUCT(*)) AS alert_body
                        FROM baseAlertQuery
                    )
                    SELECT alert_body INTO :alert_payload FROM arrayCreation;
                IF (:alert_payload != []) THEN
                    SELECT {{ api_function }}(:alert_account_name,:alert_name,:alert_environment,:alert_message_type,:alert_severity,:alert_display_message,:alert_payload)
                    INTO :alert_payload_recieved;
                    RETURN :alert_payload_recieved;
                ELSE
                    RETURN 'No notification fired';
                END IF;
            END;
        $$;
{%- endmacro -%}