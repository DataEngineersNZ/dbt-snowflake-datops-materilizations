/*
  This materialization is used for creating an alert objects.
  The idea behind this materialization is for ability to define CREATE OR REPLACE ALERT statements and have dbt use the necessary logic
  of deploying the alert in a consistent manner and logic.
*/

{%- materialization monitorial, adapter='snowflake' -%}
  {%- set is_serverless = dbt_dataengineers_materializations.config_meta_get('is_serverless', var('default_monitorial_serverless', false)) -%}
  {%- set warehouse_name_or_size = dbt_dataengineers_materializations.config_meta_get('warehouse_name_or_size', var('default_monitorial_warehouse_name_or_size', 'pc_monitorial_wh')) -%}
  {%- set object_type = dbt_dataengineers_materializations.config_meta_get('object_type', var('default_monitorial_object_type', 'alert')) -%}
  {%- set schedule = dbt_dataengineers_materializations.config_meta_get('schedule', '60 MINUTE') -%}
  {%- set severity = dbt_dataengineers_materializations.config_meta_get('severity', 'error' ) -%}
  {%- set environment =  dbt_dataengineers_materializations.config_meta_get('environment', target.name ) -%}
  {%- set display_message = dbt_dataengineers_materializations.config_meta_get('display_message', model['alias'] ) -%}
  {%- set prereq_statement = dbt_dataengineers_materializations.config_meta_get('prereq', '') -%}
  {%- set api_key = dbt_dataengineers_materializations.config_meta_get('api_key', var('default_monitorial_api_key', 'unknown') ) -%}
  {%- set message_type = dbt_dataengineers_materializations.config_meta_get('message_type', 'USER_ALERT') -%}
  {%- set delivery_type = dbt_dataengineers_materializations.config_meta_get('delivery_type', var('default_monitorial_delivery_type', 'api')) -%}
  {%- set email_integration = dbt_dataengineers_materializations.config_meta_get('email_integration', var('default_monitorial_email_integration', 'MONITORIAL_EMAIL_INTEGRATION') ) -%}
  {%- set api_function = dbt_dataengineers_materializations.config_meta_get('api_function', var('default_monitorial_api_function', 'pc_monitorial_db.utils.monitorial_dispatch') ) -%}
  {%- set error_integration = dbt_dataengineers_materializations.config_meta_get('error_integration', var('default_monitorial_error_integration', 'MONITORIAL_ERROR_INTEGRATION')) -%}
  {%- set identifier = model['alias'] -%}
  {%- set enabled_targets = dbt_dataengineers_materializations.config_meta_get('enabled_targets', [target.name]) %}
  {%- set is_enabled = target.name in enabled_targets -%}
  {%- set notification_email = var('default_monitorial_notification_email', 'notifications@monitorial.io') -%}


  -- setup
  {{ run_hooks(pre_hooks, inside_transaction=False) }}

  -- BEGIN happens here:
  {{ run_hooks(pre_hooks, inside_transaction=True) }}

  -- if the prereq_statement statement is defined in the macro code, then we need to parse it out of the sql
  {% set prereq_statements = [] %}
  {% if "--<prereq>" in sql %}
    {% set full_sql = sql.split('\n') %}
    {% for line in full_sql if "--<prereq>" in line %}
      {% if "--<prereq>" in line %}
        {% do prereq_statements.append(line) %}
      {% endif %}
    {% endfor %}
  {% else %}
        {% do prereq_statements.append(prereq_statement) %}
  {% endif %}

  {% if prereq_statements|length > 0%}
    {% set prereq_statement = prereq_statements[0] %}
    {% if "--<prereq>" in prereq_statement %}
      {% set sql = sql.replace(prereq_statement, '') %}
      {% set prereq_statement = prereq_statement.split('--<prereq>')[1] %}
      {% set prereq_statement = prereq_statement|replace(';', '') %}
    {% endif %}
  {% endif %}

      --------------------------------------------------------------------------------------------------------------------

  {%- set target_relation = api.Relation.create( identifier=identifier, schema=schema, database=database) -%}
  {% call statement('main') -%}
    {% if is_serverless == false and object_type == "alert" %}
        {% if delivery_type|lower == "email" %}
          {{ dbt_dataengineers_materializations.snowflake_create_or_replace_monitorial_alert_email_statement(target_relation,warehouse_name_or_size,schedule,message_type,severity,environment,display_message,prereq_statement,api_key,email_integration,notification_email,sql) }}
        {% else %}
          {{ dbt_dataengineers_materializations.snowflake_create_or_replace_monitorial_alert_api_statement(target_relation,warehouse_name_or_size,schedule,message_type,severity,environment,display_message,prereq_statement,api_function,sql) }}
        {% endif %}
    {% else %}
      {% if delivery_type|lower == "email" %}
        {{ dbt_dataengineers_materializations.snowflake_create_or_replace_monitorial_task_email_statement(target_relation,warehouse_name_or_size,schedule,message_type,severity,environment,display_message,prereq_statement,api_key,email_integration,notification_email,error_integration,sql) }}
      {% else %}
        {{ dbt_dataengineers_materializations.snowflake_create_or_replace_monitorial_task_api_statement(target_relation,warehouse_name_or_size,schedule,message_type,severity,environment,display_message,prereq_statement,api_function,error_integration,sql) }}
      {% endif %}
    {% endif %}
  {%- endcall %}
  {%- if is_enabled == false %}
    {% if is_serverless == false %}
      {{ dbt_dataengineers_materializations.snowflake_suspend_monitorial_alert_statement(target_relation) }}
    {% else %}
      {{ dbt_dataengineers_materializations.snowflake_suspend_monitorial_task_statement(target_relation) }}
    {% endif %}
  {% endif %}

      --------------------------------------------------------------------------------------------------------------------
  -- build model
  {{ run_hooks(post_hooks, inside_transaction=True) }}

  -- `COMMIT` happens here
  {{ adapter.commit() }}
  {{ run_hooks(post_hooks, inside_transaction=False) }}

  -- return
  {{ return({'relations': [target_relation]}) }}

{%- endmaterialization -%}
