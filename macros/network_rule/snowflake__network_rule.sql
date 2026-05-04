/*
  This materialization is used for network rule objects.
*/

{%- materialization network_rule, adapter='snowflake' -%}
  {%- set rule_type = dbt_dataengineers_materializations.config_meta_get('rule_type', 'HOST_PORT') -%}
  {%- set value_list = dbt_dataengineers_materializations.config_meta_get('value_list', []) -%}
  {%- set mode = dbt_dataengineers_materializations.config_meta_get('mode', 'INGRESS') -%}
  {%- set identifier = model['alias'] -%}

  {%- set target_relation = api.Relation.create(identifier=identifier, schema=schema, database=database) -%}
  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  -- action statement

  {%- call statement('main') -%}
      {{ dbt_dataengineers_materializations.snowflake_create_network_rule_statement(target_relation, rule_type, value_list, mode) }}
  {%- endcall -%}


  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}