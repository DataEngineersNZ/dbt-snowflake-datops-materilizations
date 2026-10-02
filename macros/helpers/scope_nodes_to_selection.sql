{% macro scope_nodes_to_selection(nodes) %}
  {#-- Restricts a list of graph nodes to those actually selected by the current dbt invocation
       (--select / --exclude), so bulk hook operations like resuming tasks/alerts or staging
       stages/file formats don't sweep up nodes outside the current selection -- including nodes
       defined in installed packages that happen to share a materialization type.

       `selected_resources` is dbt's own built-in context variable reflecting --select/--exclude
       for the current command. It has two documented blind spots:
         1. It is NOT populated when the command is `run-operation` -- and this project's hook
            macros are explicitly also invoked that way (e.g. by CI; see enable_tasks docs).
         2. It is empty during the parsing phase, before node selection has actually run.
       In both cases `selected_resources` is indistinguishable from "genuinely selected nothing",
       so rather than silently operating on zero nodes, fall back to scoping by
       `node.package_name == project_name` (nodes owned by the current/root project), which is
       always available regardless of invocation command. --#}
  {% set selection = selected_resources if (selected_resources is defined and selected_resources | length > 0) else none %}
  {% if selection is not none %}
    {{ return(nodes | selectattr("unique_id", "in", selection) | list) }}
  {% else %}
    {{ return(nodes | selectattr("package_name", "equalto", project_name) | list) }}
  {% endif %}
{% endmacro %}
