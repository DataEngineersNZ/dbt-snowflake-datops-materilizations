{{ config(
    materialized='external_access_integration',
    tags=['requires_account_admin'],
    meta={
        'network_rules_refs': ['test_network_rule'],
        'authentication_secrets_refs': ['test_secret'],
        'roles_for_use': [target.role]
    }
) }}

-- depends_on: {{ ref('test_network_rule') }}
-- depends_on: {{ ref('test_secret') }}
-- Not run in standard CI (tagged requires_account_admin): CREATE EXTERNAL ACCESS
-- INTEGRATION requires the CREATE INTEGRATION privilege on the account, which is
-- granted to ACCOUNTADMIN only by default. Still exercised by `dbt parse`/`dbt compile`
-- so the materialization's Jinja/SQL generation gets dbt 2.0 (Fusion) compile-time coverage.
-- The `-- depends_on:` comments above declare test_network_rule/test_secret as build-order
-- dependencies, since network_rules_refs/authentication_secrets_refs resolve refs inside the
-- materialization macro (not in this compiled SQL), so dbt can't otherwise see the edge.
SELECT 1
