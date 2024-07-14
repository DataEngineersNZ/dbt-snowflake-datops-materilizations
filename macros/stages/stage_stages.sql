{% macro stage_stages(enabled_targets) %}
    {% if flags.WHICH == 'run' or flags.WHICH == 'run-operation' %}
        {% if target.name in enabled_targets %}
            {% set stages_to_stage = [] %}

            {% set nodes = graph.nodes.values() if graph.nodes else [] %}
            {% for node in nodes %}
                {% if node.config.materialized == 'stage' %}
                    {% do stages_to_stage.append(node) %}
                {% endif %}
            {% endfor %}

            {% do log('stages to create: ' ~ stages_to_stage|length, info = true) %}

            {# Initial run to cater for  #}
            {% do dbt_dataengineers_materializations.stage_stages_plans(stages_to_stage) %}
        {% else %}
            {% do log('stages to create: Not enabled', info = true) %}
        {% endif %}
    {% endif %}
{% endmacro %}


{% macro stage_stages_plans(items_to_stage) %}
    {% for node in items_to_stage %}
        {% set loop_label = loop.index ~ ' of ' ~ loop.length %}
        {% do log(loop_label ~ ' START stage creation ' ~ node.schema ~ '.' ~ node.name, info = true) -%}
        
        {% set run_queue = dbt_dataengineers_materializations.get_stage_build_plan(node) %}
        {% do log(loop_label ~ ' SKIP stage ' ~ node.schema ~ '.' ~ node.name, info = true) if run_queue == [] %}
        
        {% set width = flags.PRINTER_WIDTH %}
        {% for cmd in run_queue %}
            {# do log(loop_label ~ ' ' ~ cmd, info = true) #}
            {% call statement('runner', fetch_result = True, auto_begin = False) %}
                {{ cmd }}
            {% endcall %}
            {% set runner = load_result('runner') %}
            {% set log_msg = runner['response'] if 'response' in runner.keys() else runner['status'] %}
            {% do log(loop_label ~ ' ' ~ log_msg ~ ' stage model ' ~ node.schema ~ '.' ~ node.name, info = true) %}
        {% endfor %}
    {% endfor %}
{% endmacro %}