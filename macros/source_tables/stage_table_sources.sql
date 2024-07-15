
{% macro stage_table_sources(enabled_targets) %}
    {% if target.name in enabled_targets %}
        {% if flags.WHICH == 'run' %}
            {% set sources_to_stage_auto_maintained = [] %}
            {% set externals_tables_to_stage_auto_maintained = [] %}
            {% set sources_to_stage_no_maintenance = [] %}
            {% set externals_tables_to_stage_no_maintenance = [] %}

            {% set source_nodes = graph.sources.values() if graph.sources else [] %}
            {% for node in source_nodes %}
                {% if node.external %}
                    {% if node.external.auto_create_table %}
                        {% if node.external.auto_maintained %}
                            {% if node.external.location %}
                                   {% do externals_tables_to_stage_auto_maintained.append(node) %}
                            {% else %}
                                   {% do sources_to_stage_auto_maintained.append(node) %}
                            {% endif %}
                        {% else %}
                            {% if node.external.location %}
                                   {% do sources_to_stage_no_maintenance.append(node) %}
                            {% else %}
                                   {% do sources_to_stage_if_not_exist.append(node) %}
                            {% endif %}
                        {% endif %}
                    {% endif %}
                {% endif %}
            {% endfor %}
            {# Initial run to cater for  #}
            {% do log('===> ' ~ sources_to_stage_auto_maintained|length ~  'Tables to be maintained by dbt <===', info = true) -%}
            {% do dbt_dataengineers_materializations.stage_table_sources_plans(sources_to_stage_auto_maintained, true, 'internal', true) %}
            {% do dbt_dataengineers_materializations.stage_table_sources_plans(sources_to_stage_auto_maintained, false, 'internal', true) %}
            {% do log('===> ' ~ sources_to_stage_no_maintenance|length ~  'Tables only to be created by dbt <===', info = true) -%}
            {% do dbt_dataengineers_materializations.stage_table_sources_plans(sources_to_stage_no_maintenance, true, 'internal', false) %}
            {% do dbt_dataengineers_materializations.stage_table_sources_plans(sources_to_stage_no_maintenance, false, 'internal', false) %}
            {% do log('===> ' ~ externals_tables_to_stage_auto_maintained|length ~  'Tables to be maintained by dbt (with external source) <===', info = true) -%}
            {% do dbt_dataengineers_materializations.stage_table_sources_plans(externals_tables_to_stage_auto_maintained, true, 'external', true) %}
            {% do dbt_dataengineers_materializations.stage_table_sources_plans(externals_tables_to_stage_auto_maintained, false, 'external', true) %}
            {% do log('===> ' ~ externals_tables_to_stage_no_maintenance|length ~  'only to be created by dbt  (with external source) <===', info = true) -%}
            {% do dbt_dataengineers_materializations.stage_table_sources_plans(externals_tables_to_stage_no_maintenance, true, 'external', false) %}
            {% do dbt_dataengineers_materializations.stage_table_sources_plans(externals_tables_to_stage_no_maintenance, false, 'external', false) %}
        {% endif %}
    {% else %}
        {% do log('tables creation not enabled for ' ~ target.name, info = true) %}
    {% endif %}
{% endmacro %}

{% macro stage_table_sources_plans(sources_to_stage, isFirstRun, table_type, auto_maintained) %}
    {% for node in sources_to_stage %}
        {% set loop_label = loop.index ~ ' of ' ~ loop.length %}
        {% set run_queue = dbt_dataengineers_materializations.get_source_build_plan(node, isFirstRun, table_type, auto_maintained) %}
        {% if run_queue == [] %}
            {% if table_type == 'external' %}
                {% do log(loop_label ~ ' SKIP table creation (with external source) ... ' ~  node.database ~ '.' ~ node.schema ~ '.' ~ node.identifier, info = true) if run_queue == [] %}
            {% else %}
                {% do log(loop_label ~ ' SKIP table creation ... ' ~  node.database ~ '.' ~ node.schema ~ '.' ~ node.identifier, info = true) if run_queue == [] %}
            {% endif %}
        {% else %}
            {% if isFirstRun %}
                {% do log(loop_label ~ ' START table creation (first run) ... ' ~  node.database ~ '.' ~ node.schema ~ '.' ~ node.identifier, info = true) -%}
            {% else %}
                {% if table_type == 'external' %}
                    {% do log(loop_label ~ ' START table creation (with external source) ... ' ~  node.database ~ '.' ~ node.schema ~ '.' ~ node.identifier, info = true) -%}
                {% else %}
                    {% do log(loop_label ~ ' START table creation (second run) ... ' ~  node.database ~ '.' ~ node.schema ~ '.' ~ node.identifier, info = true) -%}
                {% endif %}
            {% endif %}
            {% for cmd in run_queue %}
                {% call statement('runner', fetch_result = True, auto_begin = False) %}
                    {{ cmd }}
                {% endcall %}
                {% set runner = load_result('runner') %}
                {% set log_msg = runner['response'] if 'response' in runner.keys() else runner['status'] %}
                {% if table_type == 'external' %}
                    {% do log(loop_label ~ ' ' ~ log_msg ~ ' table (with external source) ... ' ~ node.schema ~ '.' ~ node.identifier, info = true) %}
                {% else %}
                    {% do log(loop_label ~ ' ' ~ log_msg ~ ' table ... ' ~ node.schema ~ '.' ~ node.identifier, info = true) %}
                {% endif %}

            {% endfor %}
         {% endif %}
    {% endfor %}
{% endmacro %}