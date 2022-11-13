
{% macro stage_table_sources() %}
    {% if flags.WHICH == 'run' %}
        {% set sources_to_stage = [] %}
        {% set externals_tables_to_stage = [] %}

        {% set source_nodes = graph.sources.values() if graph.sources else [] %}
        {% for node in source_nodes %}
            {% if node.external %}
                {% if node.external.auto_create_table %}
                    {% if node.external.location %}
                        {% do externals_tables_to_stage.append(node) %}
                    {% else %}
                        {% do sources_to_stage.append(node) %}
                    {% endif %}
                {% endif %}
            {% endif %}
        {% endfor %}

        {% do log('tables to create: ' ~ sources_to_stage|length, info = true) %}
        {% do log('external tables to create: ' ~ externals_tables_to_stage|length, info = true) %}

        {# Initial run to cater for  #}
        {% do dbt_dataengineers_materilizations.stage_table_sources_plans(sources_to_stage, true, 'internal') %}
        {% do dbt_dataengineers_materilizations.stage_table_sources_plans(sources_to_stage, false, 'internal') %}
        {% do dbt_dataengineers_materilizations.stage_table_sources_plans(externals_tables_to_stage, true, 'external') %}
        {% do dbt_dataengineers_materilizations.stage_table_sources_plans(externals_tables_to_stage, false, 'external') %}
        
    {% endif %}
{% endmacro %}

{% macro stage_table_sources_plans(sources_to_stage, isFirstRun, table_type) %}
    {% for node in sources_to_stage %}
        {% set loop_label = loop.index ~ ' of ' ~ loop.length %}
        {% if isFirstRun %}
            {% do log(loop_label ~ ' START First Run for source model ' ~ node.schema ~ '.' ~ node.identifier, info = true) -%}
        {% else %}
            {% if table_type == 'external' %}
                {% do log(loop_label ~ ' START External Table Creation for source model ' ~ node.schema ~ '.' ~ node.identifier, info = true) -%}
            {% else %}
                {% do log(loop_label ~ ' START Second Run for source model ' ~ node.schema ~ '.' ~ node.identifier, info = true) -%}
            {% endif %}
        {% endif %}
        {% set run_queue = dbt_dataengineers_materilizations.get_source_build_plan(node, isFirstRun, table_type) %}
        {% if table_type == 'external' %}
            {% do log(loop_label ~ ' SKIP external table ' ~ node.schema ~ '.' ~ node.identifier, info = true) if run_queue == [] %}
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
            {% if table_type == 'external' %}
                {% do log(loop_label ~ ' ' ~ log_msg ~ ' external table ' ~ node.schema ~ '.' ~ node.identifier, info = true) %}
            {% else %}
                {% do log(loop_label ~ ' ' ~ log_msg ~ ' source model ' ~ node.schema ~ '.' ~ node.identifier, info = true) %}
            {% endif %}

        {% endfor %}
    {% endfor %}
{% endmacro %}