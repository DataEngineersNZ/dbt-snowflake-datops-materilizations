{% macro enable_alerts() %}
    {% if flags.WHICH == 'run' %}
        {% do log("START: Locating alerts to resume", info=True) %}
        {% set alerts = [] %}
        {% set tasks = [] %}
        {% set nodes = graph.nodes.values() if graph.nodes else [] %}
        {% for node in nodes %}
            {% if node.config.materialized == "alert" %}
                {% if node.config.is_serverless %}
                    {% do tasks.append(node) %}
                {% else %}
                    {% do alerts.append(node) %}
                {% endif %}
            {% endif %}
        {% endfor %}

        {% if alerts|count > 0 %}
            {% do dbt_dataengineers_materilizations.resume_alerts(alerts, false) %}
        {% endif %}
        {% if tasks|count > 0 %}
            {% do dbt_dataengineers_materilizations.resume_alerts(tasks, true) %}
        {% endif %}

    {% endif %}
{% endmacro %}

{% macro resume_alerts(alert_nodes, is_task) %}
    {% for node in alert_nodes %}
        {% if target.name in node.config.enabled_targets %}
            {% set relation = api.Relation.create(database=node.database, schema=node.schema, identifier=node.name) %}
            {% if is_task %}
                {% do log('Resuming ' ~ level ~ ' task - ' ~ task_relation, info=true) %}
                {% do dbt_dataengineers_materilizations.snowflake_resume_alert_task_statement(relation) %}
            {% else %}
                {% do log('Resuming ' ~ level ~ ' alert - ' ~ alert_relation, info=true) %}
                {% do dbt_dataengineers_materilizations.snowflake_resume_alert_statement(relation) %}
            {% endif %}
        {% endif %}
    {% endfor %}
{% endmacro %}
