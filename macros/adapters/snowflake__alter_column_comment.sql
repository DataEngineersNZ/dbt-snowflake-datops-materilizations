{% macro snowflake__alter_column_comment(relation, column_dict) -%}
    {% set existing_columns = adapter.get_columns_in_relation(relation) | map(attribute="name") | list %}
    {%- if relation.is_dynamic_table -%}
        {%- set relation_type = 'table' -%}
    {%- elif relation.type is not none -%}
        {%- set relation_type = relation.type -%}
    {%- else -%}
        {%- set relation_result = run_query("select table_type from " ~  relation.database ~ ".information_schema.tables where table_name  = upper('" ~ relation.identifier ~ "')") -%}
        {%- set relation_type = relation_result.columns[0].values()[0] -%}
        {% if relation_type == 'MATERIALIZED VIEW' %}
            {% set relation_type = 'view' %}
        {% endif %}
    {% endif %}
    alter {{ relation.get_ddl_prefix_for_alter() }} {{ relation_type }} {{ relation.render() }} alter
    {% for column_name in existing_columns if (column_name in existing_columns) or (column_name|lower in existing_columns) %}
        {{ get_column_comment_sql(column_name, column_dict) }} {{- ',' if not loop.last else ';' }}
    {% endfor %}
{% endmacro %}
