{% macro assert_scope_nodes_to_selection() %}
  {#-- Proves the Path A branch of scope_nodes_to_selection: when the invoking command actually
       populates `selected_resources` (here, `dbt run --select test_scope_nodes_to_selection`),
       the helper must keep only nodes within that selection -- this model's own node -- and
       exclude everything else in the manifest, including dummy_task (owned by the dummy_package
       test dependency, a different installed package). Must run via a narrow `--select` of just
       this model (no `+` modifiers) so selected_resources contains exactly one unique_id. --#}
  {% if execute %}
    {% set own_unique_id = 'model.' ~ project_name ~ '.test_scope_nodes_to_selection' %}
    {% set dummy_unique_id = 'model.dbt_dummy_package.dummy_task' %}
    {% set scoped = dbt_dataengineers_materializations.scope_nodes_to_selection(graph.nodes.values()) %}
    {% set scoped_ids = scoped | map(attribute='unique_id') | list %}

    {% if own_unique_id not in scoped_ids %}
      {% do exceptions.raise_compiler_error("assert_scope_nodes_to_selection: expected '" ~ own_unique_id ~ "' to be included via selected_resources, got: " ~ scoped_ids) %}
    {% endif %}
    {% if dummy_unique_id in scoped_ids %}
      {% do exceptions.raise_compiler_error("assert_scope_nodes_to_selection: expected '" ~ dummy_unique_id ~ "' to be excluded by the current --select, got: " ~ scoped_ids) %}
    {% endif %}

    {{ log("assert_scope_nodes_to_selection: OK — selected_resources correctly scoped the node list to " ~ scoped_ids, info=True) }}
  {% endif %}
{% endmacro %}
