{% macro snowflake_get_task_top_parent_node(node) -%}
  {#-- Use the namespace() variables so we can set them within the for loop --#}
  {% set ns = namespace(keep_looking=True, parent_node=False) %}

  {#-- Only execute this at run-time and not at parse-time. The model entries in the graph dictionary will be incomplete or incorrect during parsing. --#}
  {% if execute %}
    {% set temp = dbt_dataengineers_materializations.snowflake_get_task_parent_node(node) %}

    {% if temp %}
      {% set ns.parent_node = temp %}
    {% else %}
      {% set ns.keep_looking = False %}
    {% endif %}

    {#-- While there is still a parent, look it up. There is no while loop in jinja so we need to fake it. --#}
    {% for n in range(100) %}
      {% if ns.keep_looking %}
        {% set temp = dbt_dataengineers_materializations.snowflake_get_task_parent_node(ns.parent_node) %}
        {% if temp %}
          {% set ns.parent_node = temp %}
        {% else %}
          {% set ns.keep_looking = False %}
        {% endif %}
      {% endif %}
    {% endfor %}
  {% endif %}

  {{ return(ns.parent_node) }}
{%- endmacro %}
