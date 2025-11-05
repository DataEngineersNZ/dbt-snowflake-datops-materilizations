This [dbt](https://github.com/dbt-labs/dbt) package contains materizations that can be (re)used across dbt projects.

> require-dbt-version: [">=1.8.0", "<2.0.0"]
----

## Installation Instructions
Add the following to your packages.yml file
```
  - git: https://github.com/DataEngineersNZ/dbt-snowflake-datops-materilizations.git
    revision: "0.2.11.2"
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
* Immutable Tables
* User Defined Functions
* Materialized View
* Generic
* Secrets
* Network Rules
* External Access Integration

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

| property              | description                                                                                              | required | default            |
| --------------------- | -------------------------------------------------------------------------------------------------------- | -------- | ------------------ |
| `materialized`        | specifies the type of materialisation to run                                                             | yes      | `stored_procedure` |
| `preferred_language`  | describes the language the stored procedure is written in                                                | no       | `sql`              |
| `override_name`       | specifies the name of the stored procedure if this is an overrider stored procedure                      | no       | `model['alias']`   |
| `parameters`          | specifes the parameters that needs to be passed when calling the stored procedure                        | no       |                    |
| `return_type`         | specifies the stored procedure return type                                                               | no       | `varchar`          |
| `execute_as`          | specifies the role that the stored procedure should be executed as. Options include `OWNER` and `CALLER` | no       | `owner`            |
| `include_copy_grants` | specifies if the stored procedure should include copy grants                                             | no       | `true`             |
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
| `timeout`                          | specifies the time limit on a single run of the task before it times out (in milliseconds)                   | no       | `3600000`        |
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

| property                 | description                                                                                     | required | default  |
| ------------------------ | ----------------------------------------------------------------------------------------------- | -------- | -------- |
| `materialized`           | specifies the type of materialisation to run                                                    | yes      | `stream` |
| `source_database`        | specifies the source database if different to the current location                              | no       |          |
| `source_database_prefix` | specifies the varaible prefix to use for the database name if different to the current location | no       |          |
| `source_schema`          | specifies the source table or view schema if different to the current location                  | no       |          |
| `source_model`           | specifies the source table or view model name to add the stream to                              | yes      |          |

## Tables
Adds the ability to create the raw tables based on the yml file

Usage

```yml
    tables:
      - name: raw_customers
        description: Customer Information
        external:
          auto_create_table: true
          auto_maintained: false
```

| property            | description                                               | required | default |
| ------------------- | --------------------------------------------------------- | -------- | ------- |
| `auto_create_table` | specifies if the table should be created by dbt or not    | yes      | `false` |
| `auto_maintained`   | specifies if the table should be maintianed by dbt or not | no       | `false` |

* it's recommended that a separate stream object is created instead of setting up the stream via the table object as the stream doesn't appear on the DAG when created via this method, nor can you reference it using the `ref` macro.

To action the auto-creation of the tables, you need to add the following pre-hook

```yml
on-run-start:
  - "{{ dbt_dataengineers_materializations.stage_table_sources(['local-dev', 'unit-test', 'test', 'prod']) }}"
```

| parameter         | description                                                       | default         |
| ----------------- | ----------------------------------------------------------------- | --------------- |
| `enabled_targets` | specifies if the materialisation should be run in the environment | `[target.name]` |

## Immutable Tables

An immutable table is a table that is created once and never updated. This is useful for tables that are used for reference data, tables that are used for audit purposes or where you will be populating via other mechanisms such as tasks or stored procedures.

``` sql
{{
    config(materialized='immutable_table')
}}
```

| property                     | description                                                                                                                                                                           | required | default           |
| ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ----------------- |
| `materialized`               | specifies the type of materialisation to run                                                                                                                                          | yes      | `immutable_table` |
| `is_transient`               | specifies if the table should be created as transient                                                                                                                                 | no       | `false`           |
| `if_not_exists`              | specifies if the table should only be created if it doesnt exist                                                                                                                      | no       | `true`            |
| `create_or_replace`          | specifies if the table should be created or replaced                                                                                                                                  | no       | `false`           |
| `data_retention_in_days`     | Specifies the retention period for the table so that Time Travel actions (SELECT, CLONE, UNDROP) can be performed on historical data in the table                                     | no       |                   |
| `max_data_extension_in_days` | Object parameter that specifies the maximum number of days for which Snowflake can extend the data retention period for the table to prevent streams on the table from becoming stale | no       |                   |
| `enable_change_tracking`     | Specifies whether to enable change tracking on the table                                                                                                                              | no       | `false`           |

## Stages
A stage is a location where data files are stored. You can use a stage to load data into a table or to unload data from a table. You can also use a stage to copy data between tables in different databases.

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
## Secrets

A secret is a secure object that stores sensitive data such as a password, OAuth token, or private key. Secrets are stored in Snowflake and can be referenced in SQL statements, stored procedures, and user-defined functions.

Usage

```sql
{{
    config(
       materialized='secret'
       , secret_type = 'GENERIC_STRING'
       , secret_string_variable = "VARIABLE_NAME"
    )
}}
```
| property                          | description                                                                                                                                                                    | Type   | Applicable For                                              | required | default          |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------ | ----------------------------------------------------------- | -------- | ---------------- |
| `materialized`                    | specifies the type of materialisation to run                                                                                                                                   | string |                                                             | yes      | `secret`         |
| `secret_type`                     | specifies the type of secret to create. Options include `GENERIC_STRING`, `PASSWORD`, `OAUTH2_CLIENT_CREDNTIALS`, `OAUTH2_AUTHORIZATION_CODE`                                  | string |                                                             | yes      | `GENERIC_STRING` |
| `secret_string_variable`          | Specifies a variable name which contains the string to store in the secret.                                                                                                    | string | `GENERIC_STRING`                                            | no       |                  |
| `username`                        | Specifies the username value to store in the secret.                                                                                                                           | string | `PASSWORD`                                                  | no       |                  |
| `password_variable`               | Specifies a variable name which contains the secret to use with basic authentication.                                                                                          | string | `PASSWORD`                                                  | no       |                  |
| `oauth_refresh_token_variable`    | Specifies the token as a string that is used to obtain a new access token from the OAuth authorization server when the access token expires.                                   | string | `OAUTH2_AUTHORIZATION_CODE`                                 | no       |                  |
| `oauth_refresh_token_expiry_time` | Specifies the timestamp as a string when the OAuth refresh token expires.                                                                                                      | string | `OAUTH2_AUTHORIZATION_CODE`                                 | no       |                  |
| `security_integration`            | Specifies the name value of the Snowflake security integration that connects Snowflake to an external service.                                                                 | string | `OAUTH2_AUTHORIZATION_CODE`,<br/>`OAUTH2_CLIENT_CREDNTIALS` | no       |                  |
| `oauth_scopes`                    | Specifies a comma-separated list of scopes to use when making a request from the OAuth server by a role with USAGE on the integration during the OAuth client credentials flow | array  | `OAUTH2_CLIENT_CREDNTIALS`                                  | no       |                  |


> The variables should be treated as environment variables and passed in at runtime. The variables should not be hardcoded in the model.

## Network Rules

Usage

```sql
{{
    config(
       materialized='network_rule'
       , rule_type = 'HOST_PORT'
       , mode = 'EGRESS'
       , value_list = ['example.com', 'company.com:443']
    )
}}
```

| property       | description                                                                                                                                                               | required | default        |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | -------------- |
| `materialized` | specifies the type of materialisation to run                                                                                                                              | yes      | `network_rule` |
| `rule_type`    | Specifies the type of network identifiers being allowed or blocked. A network rule can have only one type Options include `IPV4`, `AWSVPCEID`, `AZURELINKID`, `HOST_PORT` | yes      | `HOST_PORT`    |
| `mode`         | Specifies what is restricted by the network rule. Options include `INGRESS`, `INTERNAL_STAGE`, `EGRESS`                                                                   | yes      | `INGRESS`      |
| `value_list`   | Specifies the network identifiers that will be allowed or blocked                                                                                                         | yes      |                |

## External Access Integration

External access integrations are used to allow UDFs and stored procedures to access external network locations. External access integrations are used to store the credentials required to access the external network location.

Usage

```sql
{{
    config(
       materialized='external_access_integration'
       , authentication_secrets = [your_secret]
       , network_rules = ['your_network_rule']
       , api_authentication_integrations = ['your_api_integration']
       , role_for_creation = 'dataops_admin'
       , roles_for_use = 'developers'
    )
}}
```

| property                              | description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | required | default                       |
| ------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- | ----------------------------- |
| `materialized`                        | specifies the type of materialisation to run                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | yes      | `external_access_integration` |
| `authentication_secrets`              | Specifies the allowed network rules (fully qualified). Only egress rules may be specified                                                                                                                                                                                                                                                                                                                                                                                                                                           | no       | []                            |
| `authentication_secrets_ref`          | Specifies the allowed network rules (ref objects). Only egress rules may be specified                                                                                                                                                                                                                                                                                                                                                                                                                                               | no       | []                            |
| `network_rules`                       | Specifies the secrets (fully qualified) that UDF or procedure handler code can use when accessing the external network locations referenced in allowed network rules.                                                                                                                                                                                                                                                                                                                                                               | yes      | []                            |
| `network_rules_ref`                   | Specifies the secrets (ref objects) that UDF or procedure handler code can use when accessing the external network locations referenced in allowed network rules.                                                                                                                                                                                                                                                                                                                                                                   | yes      | []                            |
| `api_authentication_integrations`     | Specifies the security (fully qualified) integrations whose OAuth authorization server issued the secret used by the UDF or procedure. The security integration must be the type used for external API integration.                                                                                                                                                                                                                                                                                                                 | no       | []                            |
| `api_authentication_integrations_ref` | Specifies the security (ref objects) integrations whose OAuth authorization server issued the secret used by the UDF or procedure. The security integration must be the type used for external API integration.                                                                                                                                                                                                                                                                                                                     | no       | []                            |
| `role_for_creation`                   | Specifies the role which has the `Create integration role granted to it | yes | `dataops_admin`                                                                                                |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          | |          |                               |
| `roles_for_use`                       | Specifies the roles which should be granted the `usage` permission to the integration                                                                                                                                                                                                                                                                                                                                                                                                                                               | yes      | ['developers']                |

> WARNING: A Role with `CREATE INTEGRATION` roles is required to deploy this object as its an Account level object. The deployment will switch roles when deploying locally to the specified in `role_for_creation`
> The integration name will append the `target.name` to the end with the exception of deployling to a `local-dev` target in which case it will append the database name configrued for deployment replacing the text described in the variable `target_database_replacement` with ''

## Generic

Where the materialisation is not covered by the other materialisations, you can use the generic materialisation to create the object.

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
| `preferred_language` | specifies the landuage for the UDF function         | no       | `SQL`                   |
| `is_secure`          | specifies the function whether it is secure or not? | no       | `false`                 |
| `immutable`          | specifies the function is mutable or immutable      | no       | `false`                 |
| `memoizable`         | specifies the function is memoizable                | no       | `false`                 |
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

| property              | description                                                     | required | default                 |
| --------------------- | --------------------------------------------------------------- | -------- | ----------------------- |
| `materialized`        | specifies the type of materialisation to run                    | yes      | `user_defined_function` |
| `preferred_language`  | specifies the landuage for the UDF function                     | yes      | `javascript`            |
| `is_secure`           | specifies the function whether it is secure or not?             | no       | `false`                 |
| `immutable`           | specifies the function is mutable or immutable                  | no       | `false`                 |
| `return_type`         | specifies the datatype for the return value                     | yes      |                         |
| `parameters`          | specifies the parameter for the function                        | no       |                         |
| `null_input_behavior` | specifies the behavior of the function when passed a NULL value | no       | `CALLED ON NULL INPUT`  |

### Java

To create a user defined function using Java, you need to add the following config to the top of your model:

```sql
{{ 
    config(materialized='user_defined_function',
    preferred_language = 'java',
    is_secure = false,
    handler_name = "'testfunction.echoVarchar'",
    target_path = "'@~/testfunction.jar'",
    external_access_integrations = ["your_access_integration"],
    secrets = ["\'cred\' = oauth_token"]
    return_type = 'varchar',
    parameters = 'my_string varchar')
}}
```

| property                           | description                                                                   | type    | required | default                 |
| ---------------------------------- | ----------------------------------------------------------------------------- | ------- | -------- | ----------------------- |
| `materialized`                     | specifies the type of materialisation to run                                  | string  | yes      | `user_defined_function` |
| `preferred_language`               | specifies the landuage for the UDF function                                   | string  | yes      | `java`                  |
| `is_secure`                        | specifies the function whether it is secure or not?                           | boolean | no       | `false`                 |
| `immutable`                        | specifies the function is mutable or immutable                                | boolean | no       | `false`                 |
| `runtime_version`                  | specifies the version of java                                                 | string  | yes      |                         |
| `packages`                         | specifies an array of packages required for the java function                 | array   | yes      |                         |
| `external_access_integrations`     | specifies the name of the external access integration to be used              | array   | no       |                         |
| `external_access_integrations_ref` | specifies the name of the external access integration (ref object) to be used | array   | no       |                         |
| `secrets`                          | specifies an array of secrets that are to be used by the function             | array   | no       |                         |
| `handler_name`                     | specifies the combination of class and the function name                      | string  | yes      |                         |
| `imports`                          | specifies an array of imports required for the java function                  | array   | no       |                         |
| `target_path`                      | specifies the path for the jar file                                           | string  | yes      |                         |
| `return_type`                      | specifies the datatype for the return value                                   | string  | yes      |                         |
| `parameters`                       | specifies the parameter for the function                                      | string  | no       |                         |
| `null_input_behavior`              | specifies the behavior of the function when passed a NULL value               | string  | no       | `CALLED ON NULL INPUT`  |

> The external_access_integrations_ref name will append the `target.name` to the end with the exception of deployling to a `local-dev` target in which case it will append the database name configrued for deployment replacing the text described in the variable `target_database_replacement` with ''

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
    external_access_integrations = ["your_access_integration"],
    secrets = ["\'cred\' = oauth_token"]
    handler_name = 'udf',
    return_type = 'variant')
}}
```

| property                       | description                                                       | Type    | required | default                 |
| ------------------------------ | ----------------------------------------------------------------- | ------- | -------- | ----------------------- |
| `materialized`                 | specifies the type of materialisation to run                      | string  | yes      | `user_defined_function` |
| `preferred_language`           | specifies the landuage for the UDF function                       | string  | yes      | `python`                |
| `is_secure`                    | specifies the function whether it is secure or not?               | boolean | no       | `false`                 |
| `immutable`                    | specifies the function is mutable or immutable                    | boolean | no       | `false`                 |
| `return_type`                  | specifies the datatype for the return value                       | string  | yes      |                         |
| `parameters`                   | specifies the parameter for the function                          | string  | no       |                         |
| `runtime_version`              | specifies the version of python                                   | string  | yes      |                         |
| `packages`                     | specifies an array of packages required for the python function   | array   | yes      |                         |
| `handler_name`                 | specifies the handler name for the function                       | string  | yes      |                         |
| `external_access_integrations` | specifies the name of the external access integration to be used  | array   | no       |                         |
| `secrets`                      | specifies an array of secrets that are to be used by the function | array   | no       |                         |
| `imports`                      | specifies an array of imports required for the python function    | array   | no       |                         |
| `null_input_behavior`          | specifies the behavior of the function when passed a NULL value   | string  | no       | `CALLED ON NULL INPUT`  |


## Materialized View
To create a Materialized View, you need to add the following config to the top of your model:


```sql
{{ 
    config(materialized='snowflake_materialized_view',
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

### Comments

We have enhanced the `snowflake__alter_column_comment` and `snowflake__alter_relation_comment` macros to cater for comments on materialized views. This means that when you use these macros to alter comments on columns or relations within a materialized view, the changes will be properly applied.

To be able to take advantage of these, please add the following to your `dbt_project.yml` file

```yml
dispatch:
 - macro_namespace: dbt
   search_order: [dbt_dataengineers_materializations, dbt]
```