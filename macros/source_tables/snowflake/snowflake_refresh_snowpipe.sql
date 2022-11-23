{% macro snowflake_refresh_snowpipe(relation, source_node) %}

    {% set snowpipe = source_node.external.snowpipe %}
    {% set auto_ingest = snowpipe.get('auto_ingest', false) if snowpipe is mapping %}
    
    {% if auto_ingest is true %}
    
        {% do return([]) %}
    
    {% else %}
    
        {% set ddl %}
        alter pipe {{ relation.include(database=(not temporary), schema=(not temporary)) }} refresh
        {% endset %}
        
        {{ return([ddl]) }}
    
    {% endif %}
    
{% endmacro %}
