    /*
  This materialization is used for external access integration objects.
*/

{%- materialization external_access_integration, adapter='snowflake' -%}
  {%- set authentication_secrets = dbt_dataengineers_materializations.config_meta_get('authentication_secrets', []) -%}
  {%- set authentication_secrets_refs = dbt_dataengineers_materializations.config_meta_get('authentication_secrets_refs', []) -%}
  {%- set network_rules = dbt_dataengineers_materializations.config_meta_get('network_rules', []) -%}
  {%- set network_rules_refs = dbt_dataengineers_materializations.config_meta_get('network_rules_refs', []) -%}
  {%- set api_authentication_integrations = dbt_dataengineers_materializations.config_meta_get('api_authentication_integrations', []) -%}
  {%- set api_authentication_integrations_refs = dbt_dataengineers_materializations.config_meta_get('api_authentication_integrations_refs', []) -%}
  {%- set role_for_creation = dbt_dataengineers_materializations.config_meta_get('role_for_creation', 'developers') -%}
  {%- set roles_for_use = dbt_dataengineers_materializations.config_meta_get('roles_for_use', ['dataops_admin']) -%}
  {%- set identifier = model['alias'] ~ "_" ~  target.name|replace('local-dev', database|replace(var('target_database_replacement'), ''))|replace('-', '_')  %}

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  {% set ns = namespace(original_role='unknown') %}
  {% if execute %}
    {% set get_current_role_results = run_query("select current_role() as role") %}
    {% for result in get_current_role_results %}
      {% set ns.original_role = result.values()[0] %}
    {% endfor %}
  {% endif %}
  -- action statement
 {% for secret_name in authentication_secrets_refs %}
      {% do authentication_secrets.append(dbt_dataengineers_materializations.resolve_relation_ref(secret_name)) %}
 {% endfor %}
 {% for rule_name in network_rules_refs %}
      {% do network_rules.append(dbt_dataengineers_materializations.resolve_relation_ref(rule_name)) %}
 {% endfor %}
 {% for api_integration_name in api_authentication_integrations_refs %}
      {% do api_authentication_integrations.append(dbt_dataengineers_materializations.resolve_relation_ref(api_integration_name)) %}
 {% endfor %}

  {%- call statement('main') -%}
      {{ dbt_dataengineers_materializations.snowflake_create_external_access_integration_statement(identifier|upper, authentication_secrets, network_rules, api_authentication_integrations, role_for_creation, ns.original_role, roles_for_use) }}
  {%- endcall -%}


  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': []}) }}

{%- endmaterialization -%}

{% macro resolve_relation_ref(ref_name) %}
  {#-- NOTE: ref() cannot be used here. These names come from this materialization's own
       config (network_rules_refs / authentication_secrets_refs / api_authentication_integrations_refs),
       not from the model's own compiled SQL, so they are not statically-declared dependencies
       of this node — calling ref() on them trips dbt Fusion's dependency-graph validation
       with `JinjaError: not a key type: ref not found for package...` (see the identical
       note in enable_tasks.sql / snowflake__task.sql). Look the node up in the graph and
       build the relation from the current invocation's `target.database` (guaranteed
       fresh) instead. --#}
  {% set found_node = none %}
  {% if execute %}
    {% set nodes = graph.nodes.values() if graph.nodes else [] %}
    {% for node in nodes %}
      {% if node.name == ref_name %}
        {% set found_node = node %}
      {% endif %}
    {% endfor %}
  {% endif %}
  {% if found_node is none %}
    {% do exceptions.raise_compiler_error("external_access_integration: could not resolve ref '" ~ ref_name ~ "' — no model with that name was found in the graph. Ensure it is defined in this project.") %}
  {% endif %}
  {% set relation = api.Relation.create(database=target.database, schema=found_node.schema, identifier=found_node.name).include(database=True) %}
  {{ return(relation) }}
{% endmacro %}
