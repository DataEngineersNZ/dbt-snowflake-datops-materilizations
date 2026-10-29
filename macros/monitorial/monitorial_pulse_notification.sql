{#-
  The Snowflake Scripting block a Monitorial monitor (alert or task) runs: it runs the monitor query and, when
  it returns rows, sends one notification through Monitorial Pulse's notification procedure
  (`<pulse app>.api.send_notification(payload)`, set with `api_procedure` / `default_monitorial_api_procedure`).
  The payload is a Pulse notification: each row of the query becomes a list of key/value pairs in message_details.
  The role that owns the alert or task needs Pulse's MONITORIAL_ADMINISTRATOR application role.
-#}
{%- macro monitorial_pulse_notification_block(target_relation,message_type,severity,environment,display_message,prereq_statement,api_procedure,sql) -%}
            DECLARE
                alert_rows ARRAY;
                alert_payload VARIANT;
                alert_payload_received VARIANT;
            BEGIN
                {% if prereq_statement | length > 0 %}
                    {{ prereq_statement }};
                {% endif %}
                WITH baseAlertQuery AS (
                       {{ sql }}
                ),
                alertRows AS (
                        SELECT ROW_NUMBER() OVER (ORDER BY NULL) AS row_id, OBJECT_CONSTRUCT(*) AS alert_row
                        FROM baseAlertQuery
                    ),
                alertDetails AS (
                        SELECT ARRAY_AGG(details) AS alert_rows
                        FROM (
                            SELECT ARRAY_AGG(OBJECT_CONSTRUCT('key', f.key, 'value', f.value::VARCHAR)) AS details
                            FROM alertRows r, LATERAL FLATTEN(input => r.alert_row) f
                            GROUP BY r.row_id
                        )
                    )
                    SELECT alert_rows INTO :alert_rows FROM alertDetails;
                IF (ARRAY_SIZE(COALESCE(:alert_rows, [])) > 0) THEN
                    alert_payload := OBJECT_CONSTRUCT(
                        'source', 'dbt',
                        'message_type', '{{ message_type }}',
                        'object_name', '{{ target_relation.include(database=(not temporary), schema=(not temporary)) }}',
                        'environment', '{{ environment }}',
                        'severity', '{{ severity }}',
                        'message', '{{ display_message }}',
                        'message_details', :alert_rows,
                        'metadata', OBJECT_CONSTRUCT('account', CURRENT_ACCOUNT(), 'row_count', ARRAY_SIZE(:alert_rows)),
                        'requires_ack', FALSE,
                        'requires_action', FALSE);
                    CALL {{ api_procedure }}(:alert_payload) INTO :alert_payload_received;
                    RETURN TO_VARCHAR(:alert_payload_received);
                ELSE
                    RETURN 'No notification fired';
                END IF;
            END
{%- endmacro -%}
