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

{% macro resolve_node_relation(node) %}
  {#-- Builds a relation for a graph node that isn't a statically-declared dependency of the
       caller (enable_tasks, snowflake__task's top-parent lookup, resolve_relation_ref), so
       ref() can't be used. Combines three things ref() would normally give for free:
       - resolve_node_database(node): respects an explicit per-node database override, or
         falls back to target.database (see the macro above).
       - node.alias: the node's actual created identifier, not node.name (its logical/file
         name) — they diverge whenever the node sets a custom dbt alias.
       - node.config.quoting: the node's own resolved quote policy. Without this, a node
         created with a quoted identifier/schema/database is looked up here using the
         adapter's default quoting instead, which can resolve to a different or nonexistent
         object. --#}
  {% set quote_policy = node.config.quoting if (node.config is defined and node.config.quoting is defined) else {} %}
  {{ return(api.Relation.create(
      database=dbt_dataengineers_materializations.resolve_node_database(node),
      schema=node.schema,
      identifier=node.alias,
      quote_policy=quote_policy
  )) }}
{% endmacro %}

