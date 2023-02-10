{%- macro snowflake_create_alert_statement(relation, warehouse, schedule, severity, action, sql) -%}

{{ log("Creating Alert " ~ relation) }}   
CREATE OR REPLACE ALERT {{ relation.include(database=(not temporary), schema=(not temporary)) }}({{ parameters }})
    WAREHOUSE {{ warehouse }}
    SCHEDULE  {{ schedule }}
    IF( EXISTS(
        {{ sql }}
    ))
    THEN
        {% if action == "snowwatch" %}
            CALL snowwatch.sendalert('{{ relation.identifier }}', '{{ severity }}', last_query_id());
        {%- else -%}
            {{ action }}
        {%- endif -%}
    ;
{%- endmacro -%}