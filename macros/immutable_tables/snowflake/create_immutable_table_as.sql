{% macro create_immutable_table_as(relation, create_statement, is_transient, data_retention_in_days, max_data_extension_in_days, enable_change_tracking, sql) -%}

{{ create_statement }} {{ relation.include(database=(not temporary), schema=(not temporary)) }}
{% if not is_transient -%}
{%- if data_retention_in_days is not none -%}

    data_retention_time_in_days = {{ data_retention_in_days }}
{%- endif -%}
{% if max_data_extension_in_days is not none -%}

    max_data_extension_time_in_days = {{ max_data_extension_in_days }}
{%- endif -%}
{%- endif -%}
    change_tracking = {{ enable_change_tracking | upper }}
as
    {{ sql }}
;

{% endmacro %}