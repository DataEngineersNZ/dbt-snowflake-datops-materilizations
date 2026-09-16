{% macro assert_resolve_relation_ref() %}
  {#-- Runtime-tests external_access_integration's resolve_relation_ref helper without needing
       ACCOUNTADMIN: it calls the real resolver against test_network_rule/test_secret (which
       dbt run has already created by the time this operation runs) and asserts on the
       returned relation, exercising the graph lookup, alias resolution, and database
       resolution — without ever issuing CREATE EXTERNAL ACCESS INTEGRATION, which is the part
       that actually needs elevated privileges. --#}
  {% if execute %}
    {% set relation = dbt_dataengineers_materializations.resolve_relation_ref('test_network_rule') %}
    {% if relation.identifier != 'test_network_rule' %}
      {% do exceptions.raise_compiler_error("assert_resolve_relation_ref: expected identifier 'test_network_rule', got '" ~ relation.identifier ~ "'") %}
    {% endif %}
    {% if relation.database != target.database %}
      {% do exceptions.raise_compiler_error("assert_resolve_relation_ref: expected database '" ~ target.database ~ "', got '" ~ relation.database ~ "'") %}
    {% endif %}
    {% if relation.schema != target.schema %}
      {% do exceptions.raise_compiler_error("assert_resolve_relation_ref: expected schema '" ~ target.schema ~ "', got '" ~ relation.schema ~ "'") %}
    {% endif %}

    {% set secret_relation = dbt_dataengineers_materializations.resolve_relation_ref('test_secret') %}
    {% if secret_relation.identifier != 'test_secret' %}
      {% do exceptions.raise_compiler_error("assert_resolve_relation_ref: expected identifier 'test_secret', got '" ~ secret_relation.identifier ~ "'") %}
    {% endif %}

    {{ log("assert_resolve_relation_ref: OK — resolved " ~ relation ~ " and " ~ secret_relation, info=True) }}
  {% endif %}
{% endmacro %}
