{% macro enable_monitorial_monitors() %}
    {% if flags.WHICH == 'run' %}
        {% do log("START: Locating monitorial monitors to resume", info=true) %}
        {% set alerts = [] %}
        {% set tasks = [] %}
        {% set nodes = graph.nodes.values() if graph.nodes else [] %}
        {% for node in nodes %}
            {% if node.config.materialized == "monitorial" %}
                {% if node.config.is_serverless %}
                    {% do tasks.append(node) %}
                {% else %}
                    {% do alerts.append(node) %}
                {% endif %}
            {% endif %}
        {% endfor %}

        {% if alerts|count > 0 %}
            {% do dbt_dataengineers_materializations.resume_monitorial_monitors(alerts, false) %}
        {% endif %}
        {% if tasks|count > 0 %}
            {% do dbt_dataengineers_materializations.resume_monitorial_monitors(tasks, true) %}
        {% endif %}

    {% endif %}
{% endmacro %}

{% macro resume_monitorial_monitors(alert_nodes, is_task) %}
    {% for node in alert_nodes %}
        {% if target.name in node.config.enabled_targets %}
            {% set relation = api.Relation.create(database=node.database, schema=node.schema, identifier=node.name) %}
            {% if is_task %}
                {% do log('Resuming ' ~ level ~ ' monitorial task - ' ~ task_relation, info=true) %}
                {% do dbt_dataengineers_materializations.snowflake_resume_monitorial_task_statement(relation) %}
            {% else %}
                {% do log('Resuming ' ~ level ~ ' monitorial alert - ' ~ alert_relation, info=true) %}
                {% do dbt_dataengineers_materializations.snowflake_resume_monitorial_alert_statement(relation) %}
            {% endif %}
        {% endif %}
    {% endfor %}
{% endmacro %}
