{% macro enable_monitorial_monitors() %}
    {% if execute %}
    {% if flags.WHICH in ['run', 'build'] %}
        {% do log("START: Locating monitorial monitors to resume", info=true) %}
        {% set alerts = [] %}
        {% set tasks = [] %}
        {% set nodes = graph.nodes.values() if graph.nodes else [] %}
        {% for node in nodes %}
            {% if node.config.materialized == "monitorial" %}
                {% set is_serverless = dbt_dataengineers_materializations.node_config_get(node, 'is_serverless', false) %}
                {% if is_serverless %}
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
    {% endif %}
{% endmacro %}

{% macro resume_monitorial_monitors(alert_nodes, is_task) %}
    {% for node in alert_nodes %}
        {% set enabled_targets = dbt_dataengineers_materializations.node_config_get(node, 'enabled_targets', [target.name]) %}
        {% if target.name in enabled_targets %}
            {% set relation = api.Relation.create(database=node.database, schema=node.schema, identifier=node.name) %}
            {% if is_task %}
                {% do log('Resuming monitorial task - ' ~ relation, info=true) %}
                {% do dbt_dataengineers_materializations.snowflake_resume_monitorial_task_statement(relation) %}
            {% else %}
                {% do log('Resuming monitorial alert - ' ~ relation, info=true) %}
                {% do dbt_dataengineers_materializations.snowflake_resume_monitorial_alert_statement(relation) %}
            {% endif %}
        {% endif %}
    {% endfor %}
{% endmacro %}
