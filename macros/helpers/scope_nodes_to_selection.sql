{% macro scope_nodes_to_selection(nodes) %}
  {#-- Restricts a list of graph nodes to those actually selected by the current dbt invocation
       (--select / --exclude), so bulk hook operations like resuming tasks/alerts or staging
       stages/file formats don't sweep up nodes outside the current selection -- including nodes
       defined in installed packages that happen to share a materialization type.

       `selected_resources` is dbt's own built-in context variable reflecting --select/--exclude
       for the current command, and is only reliable for the 'run'/'build' commands:
         - It is NOT populated when the command is `run-operation` -- and this project's hook
           macros are explicitly also invoked that way (e.g. by CI; see enable_tasks docs).
         - It is empty during the parsing phase, before node selection has actually run.
       Gating on `flags.WHICH` (rather than checking whether `selected_resources` is empty) means
       a genuinely empty selection during an actual `run`/`build` -- e.g. `--select tag:nonexistent`
       -- is correctly honored as "select nothing", instead of being misread as "selection
       unavailable" and falling back to the whole project. For every other command (run-operation,
       parse, compile, list, debug, etc.), where `selected_resources` isn't reliable, fall back to
       scoping by `node.package_name == project_name` (nodes owned by the current/root project),
       which is always available regardless of invocation command. --#}
  {% if flags.WHICH in ['run', 'build'] %}
    {{ return(nodes | selectattr("unique_id", "in", selected_resources) | list) }}
  {% else %}
    {{ return(nodes | selectattr("package_name", "equalto", project_name) | list) }}
  {% endif %}
{% endmacro %}
