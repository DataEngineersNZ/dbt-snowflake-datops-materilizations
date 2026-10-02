{{ config(
    materialized='view',
    tags=['scope_test_only'],
    post_hook="{{ dbt_integration_tests.assert_scope_nodes_to_selection() }}"
) }}
-- Exists only to carry the post-hook assertion below; tagged scope_test_only and excluded from
-- the main build steps so it only runs when explicitly selected (see .github/workflows), which
-- is what makes dbt populate `selected_resources` with just this model's unique_id.
SELECT 1 AS placeholder
