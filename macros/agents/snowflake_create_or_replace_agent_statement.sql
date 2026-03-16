{%- macro snowflake_create_or_replace_agent_statement(target_relation, comment, profile, specification) -%}
{{ log("Creating Agent " ~ target_relation) }}
CREATE OR REPLACE AGENT {{ target_relation.include(database=(not temporary), schema=(not temporary)) }}
    {%- if comment %}
    COMMENT = '{{ comment }}'
    {%- endif %}
    {%- if profile %}
    PROFILE = '{{ profile }}'
    {%- endif %}
    FROM SPECIFICATION
    $$
{{ specification | indent(4, false) }}
    $$;
{%- endmacro -%}
