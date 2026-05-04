/*
  This materialization is used for creating stream objects.
  The idea behind this materialization is for ability to define streams ddl  and have dbt use the necessary logic
  of deploying the stream in a consistent manner and logic.
*/

{%- materialization stream, adapter='snowflake' -%}

  {%- set source_model = config_meta_get('source_model') -%}
  {%- set source_schema = config_meta_get('source_schema', schema) -%}
  {%- set source_database = config_meta_get('source_database', database) -%}
  {%- set source_database_prefix = config_meta_get('source_database_prefix', none) -%}
  {%- set source_type = config_meta_get('source_type', 'internal') -%}

  {% if source_database_prefix is not none %}
    {% set source_database_var = source_database_prefix ~ "_" ~  target.name|replace('-', '_') %}
    {% set source_database = var(source_database_var|replace("__", "_")|lower, database)   %}
  {% endif %}
  {% set target_relation = this %}
  {% set source_relation = adapter.get_relation(identifier=source_model, schema=source_schema, database=source_database) %}

  {% if source_relation == none %}
    {% set source_relation = api.Relation.create(identifier=source_model, schema=source_schema, database=source_database) %} 
  {% endif %}

  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- `BEGIN` happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  -- action statement

  {%- call statement('main') -%}
    {% if source_type == 'external' %}
      {{ snowflake_create_external_stream_statement(target_relation, source_relation) }}
    {% else %}
      {{ snowflake_create_stream_statement(target_relation, source_relation) }}
    {% endif %}
  {%- endcall -%}


  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}

  {{ run_hooks(post_hooks, inside_transaction=False) }}

  {{ return({'relations': [target_relation]}) }}
  
{%- endmaterialization -%}