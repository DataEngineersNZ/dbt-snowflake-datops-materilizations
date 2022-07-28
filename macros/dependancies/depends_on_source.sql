{% macro depends_on_source(include_for, schema, model) -%}
    {% if include_for == 'docs' %}
        {% if flags.WHICH == 'generate' %}
            -- depends on: {{ source(schema, model) }}
        {% endif %}
    {% elif include_for == 'run' %}
        {% if flags.WHICH in ('run', 'test', 'compile') %}
            -- depends on: {{ source(schema, model) }}
        {% endif %}
    {% elif include_for == 'all' %}
        -- depends on: {{ source(schema, model) }}
    {% endif %}
{%- endmacro -%}
