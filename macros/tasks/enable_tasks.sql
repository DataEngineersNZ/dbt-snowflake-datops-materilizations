
{% macro enable_tasks() %}
    {% if flags.WHICH == 'run' %}
        {% do log("START: Locating tasks to resume", info=True) %}
        {% set top_level_tasks = [] %}
        {% set child_level_tasks = [] %}
        {% set nodes = graph.nodes.values() if graph.nodes else [] %}
        {% for node in nodes %}
            {% if node.config.materialized == "task" %}
                {% set top_parent = dbt_dataengineers_materilizations.snowflake_get_task_top_parent_node(node) %}
                {% if top_parent %}
                    {% do top_level_tasks.append(top_parent) %}
                {% endif %}
                {% do child_level_tasks.append(node) %}
            {% endif %}
        {% endfor %}

        {% if child_level_tasks|count > 0 %}
            {% do dbt_dataengineers_materilizations.resume_suspended_tasks('child', child_level_tasks) %}
        {% endif %}

        {% if top_level_tasks|count > 0 %}
            {% do dbt_dataengineers_materilizations.resume_suspended_tasks('root', top_level_tasks) %}
        {% endif %}


    {% endif %}
{% endmacro %}

{% macro resume_suspended_tasks(level, task_nodes) %}
        {% for task_node in task_nodes %}
            {% if task_node.config.is_enabled %}
                {% set task_relation = api.Relation.create(database=task_node.database, schema=task_node.schema, identifier=task_node.name) %}
                {% do log('Resuming ' ~ level ~ ' task - ' ~ task_relation, info=true) %}
                {% do dbt_dataengineers_materilizations.snowflake_resume_task_statement(task_relation) %}
            {% endif %}
        {% endfor %}
{% endmacro %}
