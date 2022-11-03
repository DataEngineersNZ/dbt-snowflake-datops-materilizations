{% macro stage_file_formats() %}
    {% if flags.WHICH == 'run' or flags.WHICH == 'run-operation' %}
        {% set items_to_stage = [] %}

        {% set nodes = graph.nodes.values() if graph.nodes else [] %}
        {% for node in nodes %}
            {% if node.config.materialized == 'file_format' %}
                {% do items_to_stage.append(node) %}
            {% endif %}
        {% endfor %}

        {% do log('file formats to create: ' ~ items_to_stage|length, info = true) %}

        {# Initial run to cater for  #}
        {% if items_to_stage|length > 0 %}
            {% do dbt_dataengineers_materilizations.stage_file_format_plans(items_to_stage) %}
        {% endif %}

        
    {% endif %}
{% endmacro %}


{% macro stage_file_format_plans(items_to_stage) %}
    {% for node in items_to_stage %}
        {% set loop_label = loop.index ~ ' of ' ~ loop.length %}
        {% do log(loop_label ~ ' START file format creation ' ~ node.schema ~ '.' ~ node.name, info = true) -%}
        
        {% set run_queue = dbt_dataengineers_materilizations.get_file_format_build_plan(node) %}
        {% do log(loop_label ~ ' SKIP file format ' ~ node.schema ~ '.' ~ node.name, info = true) if run_queue == [] %}
        
        {% set width = flags.PRINTER_WIDTH %}
        {% for cmd in run_queue %}
            {# do log(loop_label ~ ' ' ~ cmd, info = true) #}
            {% call statement('runner', fetch_result = True, auto_begin = False) %}
                {{ cmd }}
            {% endcall %}
            {% set runner = load_result('runner') %}
            {% set log_msg = runner['response'] if 'response' in runner.keys() else runner['status'] %}
            {% do log(loop_label ~ ' ' ~ log_msg ~ ' file format model ' ~ node.schema ~ '.' ~ node.name, info = true) %}
        {% endfor %}
    {% endfor %}
{% endmacro %}