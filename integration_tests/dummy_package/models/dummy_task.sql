{{
  config(
    materialized='task',
    meta={
      'schedule': '60 MINUTE',
      'enabled_targets': [target.name]
    }
  )
}}
-- Lives in dbt_dummy_package, not dbt_integration_tests. enabled_targets includes
-- the current target so its own materialization resumes it on creation; the
-- integration test then explicitly suspends it and asserts enable_tasks (run via
-- `dbt run-operation`, which never populates selected_resources) correctly
-- excludes it via the package_name == project_name fallback instead of
-- resuming it again.
SELECT 1 AS placeholder
