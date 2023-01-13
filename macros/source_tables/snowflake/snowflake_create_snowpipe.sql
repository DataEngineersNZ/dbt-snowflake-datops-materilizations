{% macro snowflake_create_snowpipe(relation, source_node) %}

    {%- set external = source_node.external -%}
    {%- set snowpipe = external.snowpipe -%}

{# https://docs.snowflake.com/en/sql-reference/sql/create-pipe.html #}
    CREATE OR REPLACE PIPE {{ relation.include(database=(not temporary), schema=(not temporary)) }}
        {% if snowpipe.auto_ingest -%} AUTO_INGEST = {{snowpipe.auto_ingest}} {%- endif %}
        {% if snowpipe.aws_sns_topic -%} AWS_SNS_TOPIC = '{{snowpipe.aws_sns_topic}}' {%- endif %}
        {% if snowpipe.integration -%} INTEGRATION = '{{snowpipe.integration}}' {%- endif %}
        {% if snowpipe.error_integration -%} ERROR_INTEGRATION = '{{snowpipe.error_integration}}' {%- endif %}
        AS {{ dbt_dataengineers_materilizations.snowflake_get_copy_sql(relation, source_node) }}

{% endmacro %}
