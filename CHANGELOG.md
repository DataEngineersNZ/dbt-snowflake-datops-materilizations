# dbt_dataengineers_materializations Changelog

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

* Addition of Materialised Views
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
