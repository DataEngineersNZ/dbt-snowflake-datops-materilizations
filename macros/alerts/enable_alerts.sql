{% macro enable_alerts() %}
    {% if execute %}
    {#-- 'run-operation' must stay allowed: it's how the on-run-end hook is invoked
         explicitly (e.g. in CI, or by a user running this macro directly). --#}
    {% if flags.WHICH in ['run', 'build', 'run-operation'] %}
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
    {% endif %}
{% endmacro %}

{% macro resume_alerts(alert_nodes, is_task) %}
    {% for node in alert_nodes %}
        {% set enabled_targets = dbt_dataengineers_materializations.node_config_get(node, 'enabled_targets', [target.name]) %}
        {% if target.name in enabled_targets %}
            {% set relation = api.Relation.create(database=node.database, schema=node.schema, identifier=node.name) %}
            {% do log('Resuming alert - ' ~ relation, info=true) %}
            {% do dbt_dataengineers_materializations.snowflake_resume_alert_statement(relation) %}
        {% endif %}
    {% endfor %}
{% endmacro %}
