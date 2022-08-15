
{% macro stage_table_sources() %}
    {% if flags.WHICH == 'run' %}
        {% set sources_to_stage = [] %}
        {% set externals_to_stage = [] %}
        {% set streams_to_stage = [] %}
        {% set source_nodes = graph.sources.values() if graph.sources else [] %}
        {% for node in source_nodes %}
            {% if node.external %}
                {% if node.external.auto_create_table %}
                    {% if node.external.location != null %}
                        {% set externals_to_stage.append(node) %}
                    {% else %}
                        {% do sources_to_stage.append(node) %}
                    {% endif %}
                {% endif %}
                {% if node.external.auto_create_stream %}
                    {% do streams_to_stage.append(node) %}
                {% endif %}
            {% endif %}
        {% endfor %}

        {% do log('external sources to create: ' ~ externals_to_stage|length, info = true) %}
        {% do log('sources to create: ' ~ sources_to_stage|length, info = true) %}
        {% do log('streams to create: ' ~ streams_to_stage|length, info = true) %}

        {# Initial run to cater for  #}
        {% do dbt_dataengineers_materilizations.stage_table_sources_plans(sources_to_stage, true, false) %}
        {% do dbt_dataengineers_materilizations.stage_table_sources_plans(sources_to_stage, false, false) %}
        {% do dbt_dataengineers_materilizations.stage_table_sources_plans(streams_to_stage, false, true) %}
    {% endif %}
{% endmacro %}

{% macro stage_table_sources_plans(sources_to_stage, isFirstRun, isStream) %}
    {% for node in sources_to_stage %}
        {% set loop_label = loop.index ~ ' of ' ~ loop.length %}
        {% if isFirstRun %}
            {% do log(loop_label ~ ' START First Run for source model ' ~ node.schema ~ '.' ~ node.identifier, info = true) -%}
        {% else %}
            {% if isStream %}
                {% do log(loop_label ~ ' START Streams Creation Run for source model ' ~ node.schema ~ '.' ~ node.identifier, info = true) -%}
            {% else %}
                {% do log(loop_label ~ ' START Second Run for source model ' ~ node.schema ~ '.' ~ node.identifier, info = true) -%}
            {% endif %}
        {% endif %}
        {% set run_queue = dbt_dataengineers_materilizations.get_source_build_plan(node, isFirstRun, isStream) %}
        {% if isStream %}
            {% do log(loop_label ~ ' SKIP stream on source model ' ~ node.schema ~ '.' ~ node.identifier, info = true) if run_queue == [] %}
        {% else %}
            {% do log(loop_label ~ ' SKIP source model ' ~ node.schema ~ '.' ~ node.identifier, info = true) if run_queue == [] %}
        {% endif %}

        
        {% set width = flags.PRINTER_WIDTH %}
        {% for cmd in run_queue %}
            {# do log(loop_label ~ ' ' ~ cmd, info = true) #}
            {% call statement('runner', fetch_result = True, auto_begin = False) %}
                {{ cmd }}
            {% endcall %}
            {% set runner = load_result('runner') %}
            {% set log_msg = runner['response'] if 'response' in runner.keys() else runner['status'] %}
            {% if isStream %}
                {% do log(loop_label ~ ' ' ~ log_msg ~ ' stream on source model ' ~ node.schema ~ '.' ~ node.identifier, info = true) %}
            {% else %}
                {% do log(loop_label ~ ' ' ~ log_msg ~ ' source model ' ~ node.schema ~ '.' ~ node.identifier, info = true) %}
            {% endif %}

        {% endfor %}
    {% endfor %}
{% endmacro %}