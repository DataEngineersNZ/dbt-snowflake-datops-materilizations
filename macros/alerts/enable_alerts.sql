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
            {% do dbt_dataengineers_materilizations.resume_alerts(alerts) %}
        {% endif %}

    {% endif %}
{% endmacro %}

{% macro resume_alerts(alert_nodes) %}
    {% for node in alert_nodes %}
        {% if target.Name == 'prod' %}
            {% set is_enabled = node.config.is_enabled_prod %}
        {% elif target.Name == 'test' %}
            {% set is_enabled = node.config.is_enabled_test %}
        {% else %}
            {% set is_enabled = node.config.is_enabled_dev %}
        {% endif %}
        {% if is_enabled is none %}
            {% set is_enabled = node.config.is_enabled %}
        {% endif %}
        {% if is_enabled is none %}
            is_enabled = false
        {% endif %}
        {% if is_enabled %}
            {% set relation = api.Relation.create(database=node.database, schema=node.schema, identifier=node.name) %}
            {% do log('Resuming ' ~ level ~ ' task - ' ~ task_relation, info=true) %}
            {% do dbt_dataengineers_materilizations.snowflake_resume_alert_statement(relation) %}
        {% endif %}
    {% endfor %}
{% endmacro %}
