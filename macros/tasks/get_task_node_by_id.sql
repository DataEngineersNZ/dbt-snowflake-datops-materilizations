{% macro get_task_node_by_id(node_id) -%}
  {% set node = graph.nodes.values() | selectattr("unique_id", "equalto", node_id) | list | first %}

  {{ return(node) }}
{%- endmacro %}
