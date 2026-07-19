# dbt_dataengineers_materializations Changelog

## 1.0.6 - Gitignore & Alignment with Legacy Branch

### Changes
* Added `.cortex/`, `integration_tests/.user.yml`, and `integration_tests/package-lock.yml` to `.gitignore`
* Aligned `snowflake_create_external_table` macro formatting with `hotfix/0.2.12.2` branch

## 1.0.5 - Immutable Table Change Tracking Fix

### Bug Fixes
* Fixed Jinja type error in `immutable_table` materialization when `change_tracking` is enabled. The `| upper` filter was applied directly to a boolean value, causing `"tried to use + operator on unsupported types string and bool"`. Replaced with an explicit conditional (`'TRUE' if ... else 'FALSE'`) to produce valid SQL.

## 1.0.4 - Disable Full Refresh for Source Tables

### New Features
* Added `disable_full_refresh` property for source tables. When set to `true` under `external:`, the table will not be dropped and recreated during `--full-refresh` runs. This protects critical source tables from accidental replacement.

## 1.0.3 - External Table Load Date Fix

### Bug Fixes
* Changed `snowflake_create_external_table` macro to use `metadata$file_last_modified` instead of `current_timestamp` as the column expression for the `load_date` column. Snowflake no longer allows `current_timestamp` as a virtual column expression in external tables.

## 1.0.2 - Data Metric Function Materialization

### New Features
* Added `data_metric_function` materialization for managing Snowflake Data Metric Functions (DMFs) via dbt
* DMFs are used for data quality monitoring — they accept one or more TABLE arguments and return a NUMBER
* Config options: `table_arguments` (required), `is_secure`, `comment`, `override_name`
* Added macro documentation (`data_metric_functions.yml`)
* Added integration test (`test_data_metric_function.sql`)

## 1.0.1 - External Table FQDN Support

### Changes
* Updated `require-dbt-version` minimum from `>=1.3.0` to `>=1.9.0`
* Updated `dbt-snowflake-cortex` (Snowflake Agent Materialization) recommended revision from `1.0.0` to `1.3.0`

### Bug Fixes
* Fixed `snowflake_create_external_table` macro to accept fully qualified names (database.schema.object) for both `location` and `file_format` properties. Previously, the macro always prepended `relation.database`, which produced invalid double-prefixed references when a FQDN was already provided. The macro now detects whether the reference is already fully qualified and only prepends the database when needed.

## 1.0.0 - dbt Fusion Compatibility & Documentation

Major release with dbt Fusion engine compatibility and comprehensive documentation.

### dbt Fusion Compatibility
* Updated `require-dbt-version` to `>=1.3.0, <3.0.0` to support dbt Fusion (2.x)
* Added `config_meta_get` and `config_meta_require` helper macros for cross-engine config access
* Migrated all custom `config.get()` calls to use `config_meta_get` wrapper (checks both top-level and `meta` for backwards compatibility)
* Replaced `builtins.ref()` with standard `ref()` in external access integration materialization
* Replaced `py_current_timestring()` with `modules.datetime.datetime.now().strftime()` (Jinja-native)
* Removed all `default=` keyword arguments from `.get()` calls (Fusion's dict.get() only accepts positional args)
* Removed unused `flags.PRINTER_WIDTH` references
* Removed unused `has_transactional_hooks` / `hooks` variable references

### Bug Fixes
* Fixed `enable_tasks` hook not resuming tasks in correct order for multi-level DAGs — rewritten with bottom-up resume ordering (deepest children first, roots last)
* Fixed `enable_tasks` hook not resuming standalone root tasks (tasks with `schedule` but no children)
* Fixed `enable_tasks` hook duplicating root task suspend/resume when multiple children share the same root
* Fixed stray character in `snowflake_get_task_parent_node` macro (trailing `4` on line 11)
* Fixed `config_meta_get` triggering dbt 1.11.x `CustomKeyInConfigDeprecation` warnings by checking `meta` before falling back to `config.get()`
* Fixed `config_meta_get` triggering parse-time warnings during `dbt run-operation` by guarding the `config.get()` fallback with `{% if execute %}`
* Fixed Jinja expressions in YML doc descriptions being compiled by dbt — wrapped in `{% raw %}` tags
* Fixed `None` (Python) used instead of `none` (Jinja) as default for task timeout config
* Fixed `node.config.enabled_targets` and `node.config.is_serverless` in hook macros not resolving when configs are under `meta` (Fusion style)


### New Features
* Added `node_config_get(node, key, default)` helper macro for reading custom configs from graph node objects in hooks (checks `node.config.meta` first, falls back to `node.config`)
* Added integration test suite with 25 test models covering all materializations
* Added CI pipeline (GitHub Actions) with JWT auth, full-refresh + idempotency runs, and assertion tests
* Added task integration tests covering 3-level DAGs, fan-out patterns, and standalone roots

### Execute Guards
* Added `{% if execute %}` guards to all `run_query()` calls to prevent malformed SQL during Fusion static analysis
* Added `{% if execute %}` guards to all on-run-start/end hook macros that access `graph.nodes` or `graph.sources`
* Added defensive `none` checks on `run_query` result column access

### Hook Improvements
* Extended `flags.WHICH` checks to include `'build'` alongside `'run'` in all hook macros (`enable_tasks`, `enable_alerts`, `enable_monitorial_monitors`, `stage_file_formats`, `stage_stages`, `stage_table_sources`)
* Added `node_config_get` helper for reading custom configs from graph nodes in hooks (checks `meta` with fallback)

### Breaking Changes
* Removed `generic` materialization — incompatible with dbt 1.11.x internal framework. Use `pre-hook`/`post-hook` or `dbt run-operation` for arbitrary DDL instead


### Documentation
* Added macro documentation (YML) for all 15 materializations with config option descriptions
* Added macro documentation for all public hook macros with usage examples
* Added macro documentation for all internal helper macros
* Created YML docs for 8 previously undocumented directories: adapters, external_access_integration, helpers, immutable_tables, materialized-views, network_rule, schema, secret
* Updated README with complete setup guide, quick reference table, Fusion compatibility section, and hooks documentation

## 0.2.12.1 - Stages

* Modified `Stage` materialization to allow for the `create or replace` of a stage

## 0.2.12   - Immutable Hybrid Tables

* Modified `Immutable` materialization to allow for the creation of hybrid tables

## 0.2.11.8 - File Formats

* Fixed issue with file format generation when running as a prehook

## 0.2.11.6 - File Formats

* Fixed create or replace statements for file formats

## 0.2.11.4 - External Tables

* updated `External Table` creation so that file formats and stages originate in the database where the external table should reside

## 0.2.11.3 - File Formats

* added in the ability to specify if `create or replace` or `create if not exists` is used when creating a file format by adding the parameter `create_or_replace` to the `file_format` materialization. Default is `true` which uses `create or replace`

## 0.2.11.2 - Stored Procedures

* removed the `create_or_replace` parameter from the `stored_procedure` materialization as the create or alter doesnt allow for procedure body modifications
* modified the `copy grants` parameter to default to true as this is the most common use case

## 0.2.11.1 - Stored Procedures

* added in the ability to include `copy grants` when creating or replacing a stored procedure by adding the parameter `include_copy_grants` to the `stored_procedure` materialization
* added in the ability to specify if `create or replace` or `create or alter` is used when creating a stored procedure by adding the parameter `create_or_replace` to the `stored_procedure` materialization. Default is `true` which uses `create or replace`

## 0.2.11

* Bug fix for `materialized_view` macro to ensure that the correct SQL statements are generated for applying clustering and enabling automatic clustering
* Renamed `materialized_view` to `snowflake_materialized_view` to cater for `SnowflakeRelationType` issues discovered
* Addition of `snowflake__alter_column_comment` macro which overrides the default column comment behavior for Snowflake and takes into account materialized views
* Addition of `snowflake__alter_relation_comment` macro which overrides the default relation comment behavior for Snowflake and takes into account materialized views

## 0.2.10.2

* Bug fix for `stored_procedure` materialization to ensure that the parameters are correctly set up when no parameters are passed in

## 0.2.10.1

* Bug fix for `immutable_table` materialization to ensure that the table is created when moving from an incremental model to a table model

## 0.2.10

* Modified `immutable_table` to allow transient tables to be created, allow change tracking to be enabled and allow for the setting of the retention period
* Removed the `enable_task_dependants` macro as it is now part of the `dbt-snowflake-dataops-utils` package

## 0.2.9.3

* Bug fix for `immutable_table` materialization to ensure that the table is created when moving from an incremental model to a table model
* Bug fix for `immutable_table` materialization to ensure that the docs are correctly set up for the table

## 0.2.9.2 - User Defined Functions

* Bug fix for `udf` materialization to cater for no imports being passed in even if an empty array is passed in

## 0.2.9.1 - Dependant Tasks

* fixed up enable task dependants to ensure they only run if being executed
* fixed table staging to ensure they only run if being executed

## 0.2.9 - Immutable table

* Added new materialization for `immutable_table` to create a table that is immutable but is part of the dbt flow

## 0.2.8.3 - Task Dependants

* Bug fix for `enable_task_dependants`

## 0.2.8.2 - Task Dependants

* Added `enable_task_dependants` macro to allow for the enabling of dependant tasks

## 0.2.8.1 - Profile Targets

* Added in the ability to set the profile targets for the materializations `stages`, `file_format`, `tables`


## 0.2.8 - Secrets, Network Rules & UDF's

Addition of the materializations:

* Added `Network Rule` Materalization
* Added `Secret` Materalization
* Added `External Network Integration` Materalization
* Modified `User Defined Function` Materalization to take into account python, sql, javascript and java
* Modified `Stored Procedure` Materalization to take into account execute as permissions
* Modified source table creation to auto-create the schema if necessary
* Modified source table creation to specify if dbt is to maintain tables or not
* Modified `Stream` Materalization to take into account the `source_database` parameter correctly or use a variable for the `source_database_base` in association with a target name

## 0.2.7.6
* Task: Bug fix for utilising dependant tasks
* Materialized View: Removed the check against dropping if its a view

## 0.2.7.5
* Monitorial: Bug fix for deploying message type with models

## 0.2.7.4
Allow the use to specify a database for the object for the stream

## 0.2.7.3

* Added in the ability to add `external_access_integrations` to user defined functions
* Added in the ability to add `secrets` to user defined functions

## 0.2.7.2

* Added in ability to set the timeout seconds for the task (`timeout`)
* Added in ability to set the suspend task after number of failures (`suspend_after_number_of_failures`)

## 0.2.7.1

* Update defaults for monitorial
* Fixed spelling issues for deployment

## 0.2.7

* Modified Monitorial Alert Object with updated fields

## 0.2.7.1

* Update defaults for monitorial
* Fixed spelling issues for deployment

## 0.2.7

* Modified Monitorial Alert Object with updated fields

## 0.2.7

* Monitorial: Email Alert Updates
* Added in ability to set the timeout seconds for the task (timeout)
* Added in ability to set the suspend task after number of failures (suspend_after_number_of_failures)
* Added in the ability to add external_access_integrations to user defined functions
* Added in the ability to add secrets to user defined functions

## 0.2.6

* Modified alert materialisation to be just the Snowflake Alert Object
* Added a new materialisation for Snowflake Monitorial Alerts

## 0.2.5

* Update of Alert statement to work with Monitorial Monitors Repository so a macro can defind the Execute Immediate statement instead of in config

## 0.2.4

* Update of materialization for Snowflake Alerts to work with monitorial
* Updated Task materialization to allow enabling/disabling of tasks in different environments based on enabled_targets
* Updated creation of tables, file_format and stage in different environments based on enabled_targets
* Fixed naming of packages

## 0.2.1

* Addition of materialization for Snowflake Alerts
* Updated Task materialization to allow enabling/disabling of tasks in different environments

## 0.2.0

* Upgraded project to be compatible with dbt v1.3

## 0.1.3

* Addition of Materialized Views
* Snowpipe - auto generated column for data is now payload instead of value

## 0.1.2.4

* Snowpipe Modifications to allow for raw tables in spearate database

## 0.1.2

* Addition of the pre-hooks

* stages

## 0.1.1

* Addition of User Defined Functions materizations

## 0.1.0

Addition of the materializations:

* File Formats
* Stages
* Stored Procedures
* Tasks
* Streams
* Generic

Addition of the pre-hooks

* source tables
