{% macro enable_tasks() %}
    {% if flags.WHICH == 'run' %}
        {% do log("START: Locating tasks to resume", info=True) %}
        {% set top_level_tasks = [] %}
        {% set child_level_tasks = [] %}
        {% set child_level_tasks_to_enable = [] %}
        {% set nodes = graph.nodes.values() if graph.nodes else [] %}
        {% for node in nodes %}
            {% if node.config.materialized == "task" %}
                {% set top_parent = dbt_dataengineers_materializations.snowflake_get_task_top_parent_node(node) %}
                {% if top_parent %}
                    {% do top_level_tasks.append(top_parent) %}
                {% endif %}
                {% do child_level_tasks.append(node) %}
            {% endif %}
        {% endfor %}

        {% for node in child_level_tasks %}
            {% if node.config.task_after | length > 0 %}
                {% do child_level_tasks_to_enable.append(node) %}
            {% endif %}
        {% endfor %}

        {% if top_level_tasks|count > 0 %}
            {% do dbt_dataengineers_materializations.suspended_tasks('root', top_level_tasks) %}
        {% endif %}

        {% if child_level_tasks_to_enable|count > 0 %}
            {% do dbt_dataengineers_materializations.resume_suspended_tasks('child', child_level_tasks_to_enable) %}
        {% endif %}

        {% if top_level_tasks|count > 0 %}
            {% do dbt_dataengineers_materializations.resume_suspended_tasks('root', top_level_tasks) %}
        {% endif %}
    {% endif %}
{% endmacro %}

{% macro resume_suspended_tasks(level, task_nodes) %}
        {% for task_node in task_nodes %}
            {% if target.name in task_node.config.enabled_targets %}
                {% set task_relation = api.Relation.create(database=task_node.database, schema=task_node.schema, identifier=task_node.name) %}
                {% do log('Resuming ' ~ level ~ ' task - ' ~ task_relation, info=true) %}
                {% do dbt_dataengineers_materializations.snowflake_resume_task_statement(task_relation) %}
            {% endif %}
        {% endfor %}
{% endmacro %}

{% macro suspended_tasks(level, task_nodes) %}
        {% for task_node in task_nodes %}
            {% if target.name in task_node.config.enabled_targets %}
                {% set task_relation = api.Relation.create(database=task_node.database, schema=task_node.schema, identifier=task_node.name) %}
                {% do log('Suspending ' ~ level ~ ' task - ' ~ task_relation, info=true) %}
                {% do dbt_dataengineers_materializations.snowflake_suspend_task_statement(task_relation) %}
            {% endif %}
        {% endfor %}
{% endmacro %}
