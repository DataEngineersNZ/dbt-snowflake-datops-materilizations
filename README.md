This [dbt](https://github.com/dbt-labs/dbt) package contains materizations that can be (re)used across dbt projects.

> require-dbt-version: [">=1.3.0", "<2.0.0"]
----

## Installation Instructions
Add the following to your packages.yml file
```
  - git: https://github.com/DataEngineersNZ/dbt-snowflake-datops-materilizations.git
    revision: "0.2.7.3"
```
----

## Contents
Conatins the following materializations for Snowflake:

* Monitorial.io Monitor
* Alerts
* File Format
* Stages
* Stored Procedures
* Tasks
* Streams
* Tables
* Materialised View
* Generic

## Monitoral Alerts

Usage
```sql
{{ 
    config(materialized='monitorial',
    schedule  = '60 minute',
    diplay_message = 'your description of what is representing the alert',
    enabled_targets = ['local-dev', 'test', 'prod']
    )
}}
```
| property                 | description                                                                                                  | required | default                                      |
| ------------------------ | ------------------------------------------------------------------------------------------------------------ | -------- | -------------------------------------------- |
| `materialized`           | specifies the type of materialisation to run                                                                 | yes      | `monitorial`                                 |
| `is_serverless`          | specifies if the warehouse should be serverless (task object) or dedicated (alert object)                    | no *     | `False`                                      |
| `warehouse_name_or_size` | specifies the warehouse size if serverless otherwise the name of the warehouse to use                        | no *     | `pc_monitorial_wh`                           |
| `object_type`            | specifies the type of object to be created (options are `alert` or `task`)                                   | no *     | `alert`                                      |
| `schedule`               | specifies the schedule for periodically evaluating the condition for the alert. (CRON or minute)             | yes      | `60 minute`                                  |
| `severity`               | specifies the severity of the alert (options are `Critial`, `Error`, `Warning`, `Info`, `Debug`, `Resolved`) | no       | `error`                                      |
| `environment`            | specifies the target environment for the alert                                                               | no       | `target.name`                                |
| `display_message`        | specifies the message to be sent out with the alert                                                          | yes      |                                              |
| `prereq`                 | specifies the statement that needs to be run to feed into the alert                                          | no       | ``                                           |
| `api_key`                | specifies the monitorial api key required for authentication                                                 | no *     |                                              |
| `message_type`           | specifes the type of message to be sent, for example `User Login Failure`                                    | no       | `USER_ALERT`                                 |
| `delivery_type`          | specifies the type of delivery mechanism for the alert (options are `api` or `email`)                        | no       | `api`                                        |
| `email_integration`      | specifies the email intgeration that should be used                                                          | no *     | `EXT_EMAIL_MONITORIAL_INTEGRATION`           |
| `notification_email`     | specifies an override for where the alerts should be emailed to                                              | no *     | `pc_monitorial_db.utils.monitorial_dispatch` |
| `api_function`           | specifies the external function  that should be used when sending via api                                    | no *     | `EXT_ERROR_INTEGRATION`                      |
| `error_integration`      | specifies the error intgeration that should be used when using serverless alerts                             | no *     | `EXT_ERROR_MONITORIAL_INTEGRATION`           |
| `enabled_targets`        | specifies if the targets which the alert should be enabled for                                               | no       | `[target.name]`                              |

* `is_serverless` can be set as a global variable in the `dbt_project.yml` file using the `default_monitorial_serverless` variable
* `warehouse_name_or_size` can be set as a global variable in the `dbt_project.yml` file using the `default_monitorial_warehouse_name_or_size` variable
* `object_type` can be set as a global variable in the `dbt_project.yml` file using the `default_monitorial_object_type` variable
* `api_key` can be set as a global variable in the `dbt_project.yml` file using the `default_monitorial_api_key` variable
* `delivery_type` can be set as a global variable in the `dbt_project.yml` file using the `default_monitorial_delivery_type` variable
* `email_integration` can be set as a global variable in the `dbt_project.yml` file using the `default_monitorial_email_integration` variable
* `api_function` can be set as a global variable in the `dbt_project.yml` file using the `default_monitorial_api_function` variable
* `error_integration` can be set as a global variable in the `dbt_project.yml` file using the `default_monitorial_error_integration` variable


**Example**
```yaml
vars:
  ####################################################
  ### dbt_dataengineers_materializations variables ###
  ####################################################
  default_monitorial_email_integration: "EXT_EMAIL_MONITORIAL_INTEGRATION"
  default_monitorial_api_integration: "EXT_API_MONITORIAL_INTEGRATION"
  default_monitorial_error_integration: "EXT_ERROR_MONITORIAL_INTEGRATION"
  default_monitorial_api_function: "pc_monitorial_db.utils.monitorial_dispatch"
  default_monitorial_serverless: false
  default_monitorial_object_type: "alert"
  default_monitorial_notification_email: "notifications@monitorial.io"
  default_monitorial_warehouse_name_or_size: "pc_monitorial_wh"
  default_monitorial_api_key: "********************"
  default_delivery_type: "api"    #options are api or email
```

For more information on Monitorial.io please visit [https://www.monitorial.io/](https://www.monitorial.io/) or contact us at [info@monitorial.io](mailto:info@monitorial.io)


## Alerts

Usage
```sql
{{ 
    config(materialized='alert',
    is_serverless = False,
    action='INSERT INTO yourtable (alert_id, alert_name, result) VALUES (1, ''smaple alert'', ''sample result'')',
    warehouse_size  = 'alert_wh',
    schedule  = '60 minute',
    enabled_targets = ['local-dev', 'test', 'prod']
    )
}}
```
| property          | description                                                                                      | required | default         |
| ----------------- | ------------------------------------------------------------------------------------------------ | -------- | --------------- |
| `materialized`    | specifies the type of materialisation to run                                                     | yes      | `alert`         |
| `warehouse_size`  | specifies the warehouse size if serverless otherwise the name of the warehouse to use            | no       | `alert_wh`      |
| `schedule`        | specifies the schedule for periodically evaluating the condition for the alert. (CRON or minute) | yes      | `60 minute`     |
| `action`          | specifies the action to run after the  if exists statement                                       | no       | `monitorial`    |
| `enabled_targets` | specifies if the targets which the alert should be enabled for                                   | no       | `[target.name]` |


### We recommended using Monitorial Monitors in preference to custom alerts, as you can send the results to multiple channels and have more control over the message that is sent out.

## Stored Procedures

Usage

```sql
{{ 
    config(materialized='stored_procedure',
    preferred_language = 'sql',
    override_name = 'SAMPLE_STORE_PROC',
    parameters = 'status varchar',
    return_type = 'NUMBER(38, 0)')
}}
```

| property             | description                                                                         | required | default            |
| -------------------- | ----------------------------------------------------------------------------------- | -------- | ------------------ |
| `materialized`       | specifies the type of materialisation to run                                        | yes      | `stored_procedure` |
| `preferred_language` | describes the language the stored procedure is written in                           | no       | `sql`              |
| `override_name`      | specifies the name of the stored procedure if this is an overrider stored procedure | no       | `model['alias']`   |
| `parameters`         | specifes the parameters that needs to be passed when calling the stored procedure   | no       |                    |
| `return_type`        | specifies the stored procedure return type                                          | no       | `varchar`          |

## File Formats

Usage

```sql
{{
    config(materialized='file_format')
}}
```

| property             | description                                       | required | default       |
| -------------------- | ------------------------------------------------- | -------- | ------------- |
| `materialized`       | specifies the type of materialisation to run      | yes      | `file_format` |
| `preferred_language` | describes the language the function is written in | no       | `sql`         |

View [Snowflake `create file format` documentation](https://docs.snowflake.com/en/sql-reference/sql/create-file-format.html) for more information on the available options.

example

```sql
{{ config(materialized='file_format') }}

    type = json
    null_if = ()
    compression = none
    ignore_utf8_errors = true
```

To action the auto-creation of the file format, you need to add the following pre-hook

```yml
on-run-start:
  - "{{ dbt_dataengineers_materializations.stage_file_formats(['local-dev', 'unit-test', 'test', 'prod']) }}"
```


| parameter         | description                                                       | default         |
| ----------------- | ----------------------------------------------------------------- | --------------- |
| `enabled_targets` | specifies if the materialisation should be run in the environment | `[target.name]` |
## Tasks

Usage

```sql
{{ 
    config(materialized='task',
    is_serverless = true,
    warehouse_name_or_size = 'xsmall',
    schedule = 'using cron */2 6-20 * * * Pacific/Auckland',
    stream_name = 'stm_orders',
    enabled_targets = ['prod'])
 }}
```

| property                           | description                                                                                                  | required | default         |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------ | -------- | --------------- |
| `materialized`                     | specifies the type of materialisation to run                                                                 | yes      | `task`          |
| `is_serverless`                    | specifies if the warehouse should be serverless or dedicated                                                 | no       | `true`          |
| `warehouse_name_or_size`           | specifies the warehouse size if serverless otherwise the name of the warehouse to use                        | no       | `xsmall`        |
| `schedule`                         | specifies the schedule which the task should be run on using CRON expressions                                | no *     |                 |
| `task_after`                       | specifies the task which this task should be run after                                                       | no *     |                 |
| `stream_name`                      | specifies the stream which the task should run only if there is data available                               | no       |                 |
| `error_integration`                | specifes the error integration to use                                                                        | no *     |                 |
| `timeout`                          | specifies the time limit on a single run of the task before it times out (in milliseconds)                   | no       | `360000`        |
| `suspend_after_number_of_failures` | Specifies the number of consecutive failed task runs after which the current task is suspended automatically | no       | `0` (no limit)  |
| `enabled_targets`                  | specifies if the targets which the alert should be enabled for                                               | no       | `[target.name]` |


* only one of `schedule` or `task_after` is required.
* `error_integration` can be set as a global variable in the `dbt_project.yml` file using the `default_monitorial_error_integration` variable

**Example**
```yaml
vars:
  default_monitorial_error_integration: "EXT_ERROR_MONITORIAL_INTEGRATION"
```

## Streams

Usage

```sql
{{
    config(materialized='stream',
    source_schema='sales',
    source_model='raw_orders')
}}
```

| property        | description                                                                    | required | default  |
| --------------- | ------------------------------------------------------------------------------ | -------- | -------- |
| `materialized`  | specifies the type of materialisation to run                                   | yes      | `stream` |
| `source_schema` | specifies the source table or view schema if different to the current location | yes      |          |
| `source_model`  | specifies the source table or view model name to add the stream to             | yes      |          |

## Tables
Adds the ability to create the raw tables based on the yml file

Usage

```yml
    tables:
      - name: raw_customers
        description: Customer Information
        external:
          auto_create_table: true
```

| property            | description                                               | required | default |
| ------------------- | --------------------------------------------------------- | -------- | ------- |
| `auto_create_table` | specifies if the table should be maintianed by dbt or not | yes      | `false` |

* it's recommended that a separate stream object is created instead of setting up the stream via the table object as the stream doesn't appear on the DAG when created via this method, nor can you reference it using the `ref` macro.

To action the auto-creation of the tables, you need to add the following pre-hook

```yml
on-run-start:
  - "{{ dbt_dataengineers_materializations.stage_table_sources(['local-dev', 'unit-test', 'test', 'prod']) }}"
```

| parameter         | description                                                       | default         |
| ----------------- | ----------------------------------------------------------------- | --------------- |
| `enabled_targets` | specifies if the materialisation should be run in the environment | `[target.name]` |

## Stages

```sql
{{
    config(materialized='stage')
}}
```

| property       | description                                  | required | default |
| -------------- | -------------------------------------------- | -------- | ------- |
| `materialized` | specifies the type of materialisation to run | yes      | `stage` |

View [Snowflake `create stage` documentation](https://docs.snowflake.com/en/sql-reference/sql/create-stage.html) for more information on the available options.

To action the auto-creation of the stages before the tables get created, you need to add the following pre-hook before the `stage_table_sources` pre-hook.

```yml
on-run-start:
  - "{{ dbt_dataengineers_materializations.stage_stages(['local-dev', 'unit-test', 'test', 'prod']) }}"
```

| parameter         | description                                                       | default         |
| ----------------- | ----------------------------------------------------------------- | --------------- |
| `enabled_targets` | specifies if the materialisation should be run in the environment | `[target.name]` |

[Storage Integrations](https://docs.snowflake.com/en/sql-reference/sql/create-storage-integration.html) need to be maintained separately as you require `Create integration` privilage on the role you are using to set those up and they are global to snowflake instead of per database.

example

```sql
{{ config(materialized='stage') }}

{% if target.name == 'prod' %}
  url='azure://xxxxxxprod.blob.core.windows.net/external-tables'
{% elif target.name == 'test' %}
  url='azure://xxxxxxtest.blob.core.windows.net/external-tables'
{% elif target.name == 'dev' %}
  url='azure://xxxxxxdev.blob.core.windows.net/external-tables'
{% else %}
  url='azure://xxxxxxsandbox.blob.core.windows.net/external-tables'
{% endif %} 
  storage_integration = DATAOPS_TEMPLATE_EXTERNAL
```

## Generic

Usage

```sql
{{
    config(materialized='generic')
}}
```

| property       | description                                  | required | default   |
| -------------- | -------------------------------------------- | -------- | --------- |
| `materialized` | specifies the type of materialisation to run | yes      | `generic` |

example

```sql
{{ config(materialized='generic') }}

CREATE OR REPLACE api integration EXT_API_MONITORIAL_INTEGRATION
    api_provider = azure_api_management
    azure_tenant_id = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    azure_ad_application_id = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    api_allowed_prefixes = ('https://api.monitorial.io')
    API_KEY = 'xxxxxxxxxxxxxxxxxxxx'
    enabled = true; 
```

** Note: ** Integrations require `AccountAdmin` privilages which your `dbt` project should not be running under. It is recommended you adopt `Terraform` to deploy integrtaions out from

## User Defined Functions

When creating a user defined function, you can use a number of different languages. The following are the supported languages:

### SQL

To create a user defined function using SQL, you need to add the following config to the top of your model:

```sql
{{ 
    config(materialized='user_defined_function',
    preferred_language = 'sql',
    is_secure = false,
    immutable = false,
    return_type = 'float')
}}
```

| property             | description                                         | required | default                 |
| -------------------- | --------------------------------------------------- | -------- | ----------------------- |
| `materialized`       | specifies the type of materialisation to run        | yes      | `user_defined_function` |
| `preferred_language` | specifies the landuage for the UDF function         | no       | `sql`                   |
| `is_secure`          | specifies the function whether it is secure or not? | no       | `false`                 |
| `immutable`          | specifies the function is mutable or immutable      | no       | `false`                 |
| `return_type`        | specifies the datatype for the return value         | yes      |                         |
| `parameters`         | specifies the parameter for the function            | no       |                         |

#### Parameters
Parameters are placed into the template with no parsing. To include multiple parameters, use the syntax:
```sql
{{ 
    config(materialized='user_defined_function',
    preferred_language = 'sql',
    is_secure = false,
    immutable = false,
    return_type = 'float'
    parameters = 'first int, next float, last varchar')
}}
```
... Which is to say: provide all parameters as a single string enclosed in quotes. Use the same format as you would for native SQL.

### Javascript

To create a user defined function using Javascript, you need to add the following config to the top of your model:

```sql
{{ 
    config(materialized='user_defined_function',
    preferred_language = 'javascript',
    is_secure = True,
    immutable = false,
    return_type = 'float')
}}
```

| property             | description                                         | required | default                 |
| -------------------- | --------------------------------------------------- | -------- | ----------------------- |
| `materialized`       | specifies the type of materialisation to run        | yes      | `user_defined_function` |
| `preferred_language` | specifies the landuage for the UDF function         | yes      | `javascript`            |
| `is_secure`          | specifies the function whether it is secure or not? | no       | `false`                 |
| `immutable`          | specifies the function is mutable or immutable      | no       | `false`                 |
| `return_type`        | specifies the datatype for the return value         | yes      |                         |
| `parameters`         | specifies the parameter for the function            | no       |                         |

### Java

To create a user defined function using Java, you need to add the following config to the top of your model:

```sql
{{ 
    config(materialized='user_defined_function',
    preferred_language = 'java',
    is_secure = false,
    handler_name = "'testfunction.echoVarchar'",
    target_path = "'@~/testfunction.jar'",
    return_type = 'varchar',
    parameters = 'my_string varchar')
}}
```

| property             | description                                              | required | default                 |
| -------------------- | -------------------------------------------------------- | -------- | ----------------------- |
| `materialized`       | specifies the type of materialisation to run             | yes      | `user_defined_function` |
| `preferred_language` | specifies the landuage for the UDF function              | yes      | `java`                  |
| `is_secure`          | specifies the function whether it is secure or not?      | no       | `false`                 |
| `immutable`          | specifies the function is mutable or immutable           | no       | `false`                 |
| `handler_name`       | specifies the combination of class and the function name | yes      |                         |
| `target_path`        | specifies the path for the jar file                      | yes      |                         |
| `return_type`        | specifies the datatype for the return value              | yes      |                         |
| `parameters`         | specifies the parameter for the function                 | no       |                         |

### Python

To create a user defined function using Python, you need to add the following config to the top of your model:

```sql
{{ 
    config(materialized='user_defined_function',
    preferred_language = 'python',
    is_secure= false,
    immutable=false,
    runtime_version = '3.8',
    packages = ['numpy','pandas','xgboost==1.5.0'],
    external_access_integrations = "your_access_integration",
    secrets = ["\'cred\' = oauth_token"]
    handler_name = 'udf',
    return_type = 'variant')
}}
```

| property                       | description                                                       | required | default                 |
| ------------------------------ | ----------------------------------------------------------------- | -------- | ----------------------- |
| `materialized`                 | specifies the type of materialisation to run                      | yes      | `user_defined_function` |
| `preferred_language`           | specifies the landuage for the UDF function                       | yes      | `python`                |
| `is_secure`                    | specifies the function whether it is secure or not?               | no       | `false`                 |
| `immutable`                    | specifies the function is mutable or immutable                    | no       | `false`                 |
| `return_type`                  | specifies the datatype for the return value                       | yes      |                         |
| `parameters`                   | specifies the parameter for the function                          | no       |                         |
| `runtime_version`              | specifies the version of python                                   | yes      |                         |
| `packages`                     | specifies an array of packages required for the python function   | yes      |                         |
| `handler_name`                 | specifies the handler name for the function                       | yes      |                         |
| `external_access_integrations` | specifies the name of the external access integration to be used  | no       |                         |
| `secrets`                      | specifies an array of secrets that are to be used by the function | no       |                         |

## Materialized View
To create a Materialized View, you need to add the following config to the top of your model:


```sql
{{ 
    config(materialized='materialized_view',
    secure = false,
    cluster_by="<<your list of fields>>",
    automatic_clustering = false)
}}
```

| property               | description                                                                 | required | default             |
| ---------------------- | --------------------------------------------------------------------------- | -------- | ------------------- |
| `materialized`         | specifies the type of materialisation to run                                | yes      | `materialized_view` |
| `secure`               | specifies that the view is secure.                                          | no       | false               |
| `cluster_by`           | specifies an expression on which to cluster the materialized view.          | no       | none                |
| `automatic_clustering` | specifies if reclustering of the materialized view is automatically resumed | no       | false               |


Supported model configs: secure, cluster_by, automatic_clustering, persist_docs (relation only)

[Snowflake Documentation for Materialized Views](https://docs.snowflake.com/en/user-guide/views-materialized.html)

❗ Note: Snowflake MVs are only enabled on enterprise accounts

❗ Although Snowflake does not have drop ... cascade, if the base table table of a MV is dropped and recreated, the MV also needs to be dropped and recreated, otherwise the following error will appear:

> Failure during expansion of view 'TEST_MV': SQL compilation error: Materialized View TEST_MV is invalid.

