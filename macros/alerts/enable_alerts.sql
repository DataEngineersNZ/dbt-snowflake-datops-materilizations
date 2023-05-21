{% macro enable_alerts() %}
    {% if flags.WHICH == 'run' %}
        {% do log("START: Locating alerts to resume", info=True) %}
        {% set alerts = [] %}
        {% set nodes = graph.nodes.values() if graph.nodes else [] %}
        {% for node in nodes %}
            {% if node.config.materialized == "alert" %}
                {% do alerts.append(node) %}
            {% endif %}
        {% endfor %}

        {% if alerts|count > 0 %}
            {% do dbt_dataengineers_materializations.resume_alerts(alerts, false) %}
        {% endif %}

    {% endif %}
{% endmacro %}

{% macro resume_alerts(alert_nodes, is_task) %}
    {% for node in alert_nodes %}
        {% if target.name in node.config.enabled_targets %}
            {% set relation = api.Relation.create(database=node.database, schema=node.schema, identifier=node.name) %}
            {% do log('Resuming ' ~ level ~ ' alert - ' ~ alert_relation, info=true) %}
            {% do dbt_dataengineers_materializations.snowflake_resume_alert_statement(relation) %}
        {% endif %}
    {% endfor %}
{% endmacro %}
