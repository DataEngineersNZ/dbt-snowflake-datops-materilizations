{% macro enable_tasks() %}
    {% if execute %}
    {#-- 'run-operation' must stay allowed: it's how the on-run-end hook is invoked
         explicitly (e.g. in CI, or by a user running this macro directly). Only
         parse-only invocations (compile, parse, list, debug, etc.) should be excluded. --#}
    {% if flags.WHICH in ['run', 'build', 'run-operation'] %}
        {% do log("START: Locating tasks to resume", info=True) %}

        {# Collect all task nodes and classify them #}
        {% set root_tasks = [] %}
        {% set child_tasks = [] %}
        {% set seen_root_ids = [] %}
        {% set nodes = graph.nodes.values() if graph.nodes else [] %}

        {% for node in nodes %}
            {% if node.config.materialized == "task" %}
                {% set task_after = dbt_dataengineers_materializations.node_config_get(node, 'task_after', '') %}
                {% if task_after | length > 0 %}
                    {% do child_tasks.append(node) %}
                {% else %}
                    {# This is a root task (has schedule, no task_after) #}
                    {% if node.unique_id not in seen_root_ids %}
                        {% do root_tasks.append(node) %}
                        {% do seen_root_ids.append(node.unique_id) %}
                    {% endif %}
                {% endif %}
            {% endif %}
        {% endfor %}

        {# Also find root tasks that are parents of child tasks but might not be in the current selection #}
        {% for node in child_tasks %}
            {% set top_parent = dbt_dataengineers_materializations.snowflake_get_task_top_parent_node(node) %}
            {% if top_parent and top_parent.unique_id not in seen_root_ids %}
                {% do root_tasks.append(top_parent) %}
                {% do seen_root_ids.append(top_parent.unique_id) %}
            {% endif %}
        {% endfor %}

        {# Sort child tasks by depth (deepest first) so we resume bottom-up #}
        {% set child_tasks_with_depth = [] %}
        {% for node in child_tasks %}
            {% set ns = namespace(depth=0, current=node) %}
            {% for i in range(100) %}
                {% set parent = dbt_dataengineers_materializations.snowflake_get_task_parent_node(ns.current) %}
                {% if parent %}
                    {% set ns.depth = ns.depth + 1 %}
                    {% set ns.current = parent %}
                {% endif %}
            {% endfor %}
            {% do child_tasks_with_depth.append({'node': node, 'depth': ns.depth}) %}
        {% endfor %}

        {# Step 1: Suspend all root tasks (must be done before modifying any child) #}
        {% do log("Suspending " ~ root_tasks|count ~ " root task(s)", info=True) %}
        {% for task_node in root_tasks %}
            {% set enabled_targets = dbt_dataengineers_materializations.node_config_get(task_node, 'enabled_targets', [target.name]) %}
            {% if target.name in enabled_targets %}
                {% set task_relation = ref(task_node.package_name, task_node.name) %}
                {% do log('  Suspending root task - ' ~ task_relation, info=true) %}
                {% do dbt_dataengineers_materializations.snowflake_suspend_task_statement(task_relation) %}
            {% endif %}
        {% endfor %}

        {# Step 2: Resume child tasks deepest-first (bottom-up ordering) #}
        {% set sorted_children = child_tasks_with_depth | sort(attribute='depth', reverse=true) %}
        {% do log("Resuming " ~ sorted_children|count ~ " child task(s)", info=True) %}
        {% for item in sorted_children %}
            {% set task_node = item.node %}
            {% set enabled_targets = dbt_dataengineers_materializations.node_config_get(task_node, 'enabled_targets', [target.name]) %}
            {% if target.name in enabled_targets %}
                {% set task_relation = ref(task_node.package_name, task_node.name) %}
                {% do log('  Resuming child task (depth ' ~ item.depth ~ ') - ' ~ task_relation, info=true) %}
                {% do dbt_dataengineers_materializations.snowflake_resume_task_statement(task_relation) %}
            {% endif %}
        {% endfor %}

        {# Step 3: Resume root tasks last (top-down, after all children are resumed) #}
        {% do log("Resuming " ~ root_tasks|count ~ " root task(s)", info=True) %}
        {% for task_node in root_tasks %}
            {% set enabled_targets = dbt_dataengineers_materializations.node_config_get(task_node, 'enabled_targets', [target.name]) %}
            {% if target.name in enabled_targets %}
                {% set task_relation = ref(task_node.package_name, task_node.name) %}
                {% do log('  Resuming root task - ' ~ task_relation, info=true) %}
                {% do dbt_dataengineers_materializations.snowflake_resume_task_statement(task_relation) %}
            {% endif %}
        {% endfor %}

        {% do log("DONE: Task resume complete", info=True) %}
    {% endif %}
    {% endif %}
{% endmacro %}
