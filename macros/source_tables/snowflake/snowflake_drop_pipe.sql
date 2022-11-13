{% macro snowflake_drop_pipe(target_relation) %}
    DROP PIPE IF EXISTS  {{ target_relation.include(database=(not temporary), schema=(not temporary)) }};   
{% endmacro %}