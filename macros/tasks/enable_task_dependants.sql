{% macro enable_task_dependants(root_task, enabled_targets) %}
{{ log("START - Enabling task and dependant tasks for " ~ root_task , info=True) }}
    {%- if execute -%}
        {% if target.name in enabled_targets -%}
            {% if flags.WHICH == 'run' %}
                {% set nodes = graph.nodes.values() if graph.nodes else [] %}
                 {% set matching_nodes = nodes
                    | selectattr("name", "equalto", root_task | lower)
                    | selectattr("config.materialized", "equalto", "task")
                %}
                {% for node in matching_nodes %}
                    {% set task_relation = api.Relation.create(database=target.database, schema=target.schema, identifier=node.name) %}
                    {{ log("Enabling task and dependant tasks: " ~ task_relation, info=True) }}
                    {% call statement('enable_depenant_tasks') %}
                        {% do dbt_dataengineers_materializations.snowflake_resume_task_with_dependants_statement(task_relation) %}
                    {% endcall %}
                {% endfor %}
            {% endif %}
        {% endif %}
    {% endif %}
{{ log("END - Enabling task and dependant tasks for " ~ root_task , info=True) }}
{% endmacro %}