{% macro snowflake_get_task_parent_node(node) -%}
  {% set parent_node = False %}
  {% set taskCounter = 0 %}
  {% set task_index_number = 0 %}
  {% set parent_tasks = [] %}

  {% if node %}
    {% if node.config.materialized == "task" %}
      {% if node.depends_on.nodes|count > 1 %}
        {% for index in range(0, node.depends_on.nodes|count -1) %}
          {% set model_detail = dbt_dataengineers_materilizations.get_task_node_by_id(node.depends_on.nodes[index]) %}4
          {%if model_detail.config.materialized == "task" %}
            {% set taskCounter = taskCounter + 1 %}
            {% set task_index_number = index %}
            {% do parent_tasks.append(model_detail) %}
          {% endif %}
        {% endfor %}
        {% if parent_tasks|count > 1 %}
          {{ exceptions.raise_compiler_error("Current node " ~ node.unique_id ~ " has " ~ taskCounter ~ " parent tasks (can only have 1)") }}
        {% elif parent_tasks|count == 1 %}
          {{ return(parent_tasks[0]) }}
        {% endif %}
      {% endif %}
    {% endif %}
  {% endif %}

  
  {{ return(none) }}
{%- endmacro %}


