{% macro snowflake_migrate_data(backup_relation, target_relation, source_node) %}

    {% set dest_columns = adapter.get_columns_in_relation(backup_relation) %}
    {% set unique_key = source_node.external.unique_key  %}
    {{ get_merge_sql(target_relation, backup_relation, unique_key, dest_columns) }}
{% endmacro %}