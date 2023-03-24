This [dbt](https://github.com/dbt-labs/dbt) package contains materizations that can be (re)used across dbt projects.

> require-dbt-version: [">=1.3.0", "<2.0.0"]
----

## Installation Instructions
Add the following to your packages.yml file
```
  - git: https://github.com/DataEngineersNZ/dbt-snowflake-datops-materilizations.git
    revision: "0.2.1"
```
----

## Contents
Conatins the following materializations for Snowflake:

* Alerts
* File Format
* Stages
* Stored Procedures
* Tasks
* Streams
* Tables
* Materialised View
* Generic

## Alerts

Usage
```sql
{{ 
    config(materialized='alert',
    warehouse  = 'alert_wh',
    schedule  = '60 minute',
    action = 'monitorial',
    description = 'your description of what is representing the alert'
    notification_email = 'notifications@monitorial.io',
    api_key = '********************************',
    notification_integration = 'EXT_EMAIL_INTEGRATION'
    )
}}
```
| property                   | description                                                                                      | required | default                       |
| -------------------------- | ------------------------------------------------------------------------------------------------ | -------- | ----------------------------- |
| `materialized`             | specifies the type of materialisation to run                                                     | yes      | `alert`                       |
| `warehouse`                | specifies the virtual warehouse that provides compute resources for executing this alert         | yes      | `alert_wh`                    |
| `schedule`                 | specifies the schedule for periodically evaluating the condition for the alert. (CRON or minute) | yes      | `60 minute`                   |
| `action`                   | specifies the action to run (either 'monitorial' or enter your own action)                       | no       | `monitorial`                  |
| `notification_email`       | specifies an override for where the alerts should be emailed to                                  | no *     | `notifications@monitorial.io` |
| `api_key`                  | specifies the api key required to authenticate the message                                       | no *     | ``                            |
| `description`              | specifies the description of the alert                                                           | no *     | ``                            |
| `execute_immediate`        | specifies the statement that needs to be run to feed into the alert                              | no *     | ``                            |
| `notification_integration` | specifies the email intgeration that should be used                                              | no *     | `EXT_EMAIL_INTEGRATION`       |
| `is_enabled_prod`          | specifies if the alert should be enabled in production environment                               | no       | `true`                        |
| `is_enabled_test`          | specifies if the alert should be enabled in test environment                                     | no       | `false`                       |
| `is_enabled_dev`           | specifies if the alert should be enabled in non prod or test environments                        | no       | `false`                       |

* only required if `action` is set to `monitorial`
* `notification_email` can be set as a global variable in the `dbt_project.yml` file using the `alert_notification_email` variable
* `notification_integration` can be set as a global variable in the `dbt_project.yml` file using the `alert_notification_integration` variable
* `api_key` can be set as a global variable in the `dbt_project.yml` file using the `alert_notification_api_key` variable

**Example**
```yaml
vars:
  alert_notification_email: "notifications@monitorial.io"
  alert_notification_integration: "EXT_EMAIL_INTEGRATION"
  alert_notification_api_key: "********-****-****-****-************"
```

For more information on snowwatch please visit [https://www.dataengineers.co.nz/solutions/snowwatch/](https://www.dataengineers.co.nz/solutions/snowwatch/) or contact us at [info@monitorial.io](mailto:info@monitorial.io)


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
  - "{{ dbt_dataengineers_materilizations.stage_file_formats(true, true, true) }}"
```


| parameter       | description                                                             | default |
| --------------- | ----------------------------------------------------------------------- | ------- |
| is_enabled_dev  | specifies if the materialisation should be run in non prod environments | `true`  |
| is_enabled_test | specifies if the materialisation should be run in test environments     | `true`  |
| is_enabled_prod | specifies if the materialisation should be run in prod environments     | `true`  |

## Tasks

Usage

```sql
{{ 
    config(materialized='task',
    is_serverless = true,
    warehouse_name_or_size = 'xsmall',
    schedule = 'using cron */2 6-20 * * * Pacific/Auckland',
    stream_name = 'stm_orders',
    is_enabled = false)
 }}
```

| property                 | description                                                                                     | required | default  |
| ------------------------ | ----------------------------------------------------------------------------------------------- | -------- | -------- |
| `materialized`           | specifies the type of materialisation to run                                                    | yes      | `task`   |
| `is_serverless`          | specifies if the warehouse should be serverless or dedicated                                    | no       | `true`   |
| `warehouse_name_or_size` | specifies the warehouse size if serverless otherwise the name of the warehouse to use           | no       | `xsmall` |
| `schedule`               | specifies the schedule which the task should be run on using CRON expressions                   | no *     |          |
| `task_after`             | specifies the task which this task should be run after                                          | no *     |          |
| `stream_name`            | specifies the stream which the task should run only if there is data available                  | no       |          |
| `error_integration`      | specifes the error integration to use                                                           | no       |          |
| `is_enabled`             | specifies if the task should be enabled or disabled at the end of the run                       | yes      | `true`   |
| `is_enabled_prod`        | specifies if the alert should be enabled in production environment  at the end of the run       | no       | `true`   |
| `is_enabled_test`        | specifies if the alert should be enabled in test environment at the end of the run              | no       | `false`  |
| `is_enabled_dev`         | specifies if the alert should be enabled in non prod or test environments at the end of the run | no       | `false`  |

* only one of `schedule` or `task_after` is required.

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
  - "{{ dbt_dataengineers_materilizations.stage_table_sources(true, true, true) }}"
```

| parameter       | description                                                             | default |
| --------------- | ----------------------------------------------------------------------- | ------- |
| is_enabled_dev  | specifies if the materialisation should be run in non prod environments | `true`  |
| is_enabled_test | specifies if the materialisation should be run in test environments     | `true`  |
| is_enabled_prod | specifies if the materialisation should be run in prod environments     | `true`  |

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
  - "{{ dbt_dataengineers_materilizations.stage_stages(true, true, true) }}"
```

| parameter       | description                                                             | default |
| --------------- | ----------------------------------------------------------------------- | ------- |
| is_enabled_dev  | specifies if the materialisation should be run in non prod environments | `true`  |
| is_enabled_test | specifies if the materialisation should be run in test environments     | `true`  |
| is_enabled_prod | specifies if the materialisation should be run in prod environments     | `true`  |

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

CREATE OR REPLACE api integration SnowWatch_Prod_API
    api_provider = azure_api_management
    azure_tenant_id = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    azure_ad_application_id = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    api_allowed_prefixes = ('https://de-snowwatch-prod-ae-apim.azure-api.net')
    API_KEY = 'xxxxxxxxxxxxxxxxxxxx'
    enabled = true; 
```

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
    packages = "('numpy','pandas','xgboost==1.5.0')",
    handler_name = 'udf',
    return_type = 'variant')
}}
```

| property             | description                                             | required | default                 |
| -------------------- | ------------------------------------------------------- | -------- | ----------------------- |
| `materialized`       | specifies the type of materialisation to run            | yes      | `user_defined_function` |
| `preferred_language` | specifies the landuage for the UDF function             | yes      | `python`                |
| `is_secure`          | specifies the function whether it is secure or not?     | no       | `false`                 |
| `immutable`          | specifies the function is mutable or immutable          | no       | `false`                 |
| `return_type`        | specifies the datatype for the return value             | yes      |                         |
| `parameters`         | specifies the parameter for the function                | no       |                         |
| `runtime_version`    | specifies the version of python                         | yes      |                         |
| `packages`           | specifies the packages required for the python function | yes      |                         |
| `handler_name`       | specifies the handler name for the function             | yes      |                         |


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

