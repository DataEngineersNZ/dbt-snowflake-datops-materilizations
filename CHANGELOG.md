# dbt_dataengineers_materializations Changelog

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
