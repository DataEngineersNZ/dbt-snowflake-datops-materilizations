-- funcsign: (relation, string) -> string
{% macro snowflake__alter_relation_comment(relation, relation_comment) -%}
    {%- if relation.is_dynamic_table -%}
        {%- set relation_type = 'dynamic table' -%}
    {%- elif relation.type is not none -%}
        {%- set relation_type = relation.type -%}
    {%- else -%}
        {%- if execute -%}
            {%- set relation_result = run_query("select table_type from " ~  relation.database ~ ".information_schema.tables where table_name  = upper('" ~ relation.identifier ~ "')") -%}
            {%- if relation_result and relation_result | length > 0 -%}
                {%- set relation_type = relation_result.columns[0].values()[0] -%}
            {%- else -%}
                {%- set relation_type = 'table' -%}
            {%- endif -%}
        {%- else -%}
            {%- set relation_type = 'table' -%}
        {%- endif -%}
    {% endif %}
    comment on {{ relation_type }} {{ relation.render() }} IS $${{ relation_comment | replace('$', '[$]') }}$$;
{% endmacro %}