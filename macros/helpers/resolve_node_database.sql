{% macro resolve_node_database(node) %}
  {#-- Used wherever a relation is built for a graph node that isn't a statically-declared
       dependency (enable_tasks, snowflake__task's top-parent lookup, resolve_relation_ref),
       so ref() can't be used to get a correctly-scoped database. Two competing failure modes:

       1. If the node explicitly overrides its `database` config, that override must be
          respected — the object was actually created there, not in `target.database`.
       2. If the node does NOT override `database`, its cached `node.database` attribute can
          be stale when a manifest built for one environment is reused in another (see the
          1.0.7 changelog entry for `snowflake__task`). `target.database` (the current
          invocation's own database) is guaranteed fresh for that case.

       `node.unrendered_config` only contains keys the user actually wrote, so checking for
       'database' there (rather than the always-populated `node.database` attribute) is how
       we tell an explicit override apart from an inherited default. --#}
  {% if node.unrendered_config is defined and node.unrendered_config.get('database') %}
    {{ return(node.database) }}
  {% else %}
    {{ return(target.database) }}
  {% endif %}
{% endmacro %}
