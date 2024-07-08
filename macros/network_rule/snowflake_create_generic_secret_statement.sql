{%- macro snowflake_create_network_rule_statement(target_relation, rule_type, value_list, mode) -%}
create network rule if not exists {{ target_relation.include(database=(not temporary), schema=(not temporary)) }}
type = {{ rule_type }}
value_list = ('{{ value_list|join(', ') }}')
{%- if rule_type|upper == 'HOST_PORT' %}
mode = EGRESS
{%- else -%}
mode = {{ mode }}
{%- endif -%};
{%- endmacro -%}