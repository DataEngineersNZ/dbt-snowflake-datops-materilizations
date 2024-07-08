/*
  This materialization is used for network rule objects.
*/

{%- materialization network_rule, adapter='snowflake' -%}
  {%- set rule_type = config.get('rule_type', default='ipv4') -%}
  {%- set value_list = config.get('value_list', default=[]) -%}
  {%- set mode = config.get('mode', default='ingress') -%}

  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}
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