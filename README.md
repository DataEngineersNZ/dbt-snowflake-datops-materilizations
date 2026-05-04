# dbt_dataengineers_materializations

This [dbt](https://github.com/dbt-labs/dbt) package contains custom materializations for managing Snowflake infrastructure objects via dbt. It supports both **dbt Core** (>=1.3.0) and the **dbt Fusion engine** (2.x).

> require-dbt-version: [">=1.3.0", "<3.0.0"]

----

## Installation

Add the following to your `packages.yml` file:
```yaml
  - git: https://github.com/DataEngineersNZ/dbt-snowflake-datops-materilizations.git
    revision: "1.0.0"
```

For Snowflake Agent Materialization add the following:
```yaml
  - git: https://github.com/monitorial-io/dbt-snowflake-cortex.git
    revision: "1.0.0"
```

----

## Quick Reference

| Materialization | Creates | Key Configs | Section |
|---|---|---|---|
| `monitorial` | Snowflake Alert/Task for Monitorial.io | `schedule`, `severity`, `delivery_type` | [Monitorial Alerts](#monitorial-alerts) |
| `alert` | Snowflake Alert | `schedule`, `action`, `warehouse_size` | [Alerts](#alerts) |
| `stored_procedure` | Stored Procedure | `preferred_language`, `parameters`, `return_type` | [Stored Procedures](#stored-procedures) |
| `file_format` | File Format | `create_or_replace` | [File Formats](#file-formats) |
| `task` | Snowflake Task | `schedule`/`task_after`, `is_serverless` | [Tasks](#tasks) |
| `stream` | Stream on table/view | `source_model`, `source_schema` | [Streams](#streams) |
| `immutable_table` | Table (CREATE IF NOT EXISTS) | `transient`, `is_hybrid`, `create_or_replace` | [Immutable Tables](#immutable-tables) |
| `stage` | Internal/External Stage | `create_or_replace` | [Stages](#stages) |
| `secret` | Secret object | `type`, `secret_string_variable` | [Secrets](#secrets) |
| `network_rule` | Network Rule | `rule_type`, `value_list`, `mode` | [Network Rules](#network-rules) |
| `external_access_integration` | External Access Integration | `network_rules`, `authentication_secrets` | [External Access Integration](#external-access-integration) |
| `general_ddl` | Any DDL (freeform SQL) | none | [General DDL](#general-ddl) |
| `user_defined_function` | UDF (SQL/Python/Java/JS/External) | `preferred_language`, `return_type`, `parameters` | [User Defined Functions](#user-defined-functions) |
| `snowflake_materialized_view` | Materialized View | `secure`, `cluster_by`, `automatic_clustering` | [Materialized View](#materialized-view) |

----

## Complete Setup

Add the following to your `dbt_project.yml`:

```yaml
dispatch:
  - macro_namespace: dbt
    search_order: [dbt_dataengineers_materializations, dbt]

on-run-start:
  - "{{ dbt_dataengineers_materializations.stage_file_formats(['prod', 'test']) }}"
  - "{{ dbt_dataengineers_materializations.stage_stages(['prod', 'test']) }}"
  - "{{ dbt_dataengineers_materializations.stage_table_sources(['prod', 'test']) }}"

on-run-end:
  - "{{ dbt_dataengineers_materializations.enable_tasks() }}"
  - "{{ dbt_dataengineers_materializations.enable_alerts() }}"
  - "{{ dbt_dataengineers_materializations.enable_monitorial_monitors() }}"

vars:
  default_monitorial_email_integration: "EXT_EMAIL_MONITORIAL_INTEGRATION"
  default_monitorial_error_integration: "EXT_ERROR_MONITORIAL_INTEGRATION"
  default_monitorial_api_function: "pc_monitorial_db.utils.monitorial_dispatch"
  default_monitorial_serverless: false
  default_monitorial_warehouse_name_or_size: "pc_monitorial_wh"
  default_monitorial_api_key: "your-api-key"
  default_monitorial_delivery_type: "api"
```

| Hook | Type | Purpose |
|---|---|---|
| `stage_file_formats` | on-run-start | Pre-creates file format objects |
| `stage_stages` | on-run-start | Pre-creates stage objects |
| `stage_table_sources` | on-run-start | Auto-creates/maintains source tables |
| `enable_tasks` | on-run-end | Resumes task objects (handles DAG ordering) |
| `enable_alerts` | on-run-end | Resumes alert objects |
| `enable_monitorial_monitors` | on-run-end | Resumes monitorial objects |

All on-run-start hooks accept `enabled_targets` and `enabled_profiles` parameters. They run during `dbt run` and `dbt build`. Add only the hooks you need.

----

## dbt Fusion Compatibility

This package supports both **dbt Core** and **dbt Fusion**. In Fusion, custom config keys must be nested under `meta`. All examples in this README use the Fusion-compatible `meta` style.

**dbt Core style (also works, for backwards compatibility):**
```sql
{{ config(materialized='task', schedule='60 MINUTE', enabled_targets=['prod']) }}
```

**dbt Fusion style (recommended, used throughout this README):**
```sql
{{ config(materialized='task', meta={'schedule': '60 MINUTE', 'enabled_targets': ['prod']}) }}
```

Both styles work transparently via the `config_meta_get` helper. Custom config keys (anything other than `materialized`, `schema`, `database`, `tags`, `grants`, `meta`, `persist_docs`, `cluster_by`, `enabled`) should be placed under `meta`.

### Helper Macros

```sql
{%- set schedule = dbt_dataengineers_materializations.config_meta_get('schedule', '60 MINUTE') -%}
{%- set source_model = dbt_dataengineers_materializations.config_meta_require('source_model') -%}
```

----

## Hooks

### on-run-start

**stage_file_formats** - Pre-creates file format objects.
```yaml
- "{{ dbt_dataengineers_materializations.stage_file_formats(['prod', 'test']) }}"
```

**stage_stages** - Pre-creates stage objects.
```yaml
- "{{ dbt_dataengineers_materializations.stage_stages(['prod', 'test']) }}"
```

**stage_table_sources** - Auto-creates and maintains source tables from YML definitions.
```yaml
- "{{ dbt_dataengineers_materializations.stage_table_sources(['prod', 'test']) }}"
```

### on-run-end

**enable_tasks** - Resumes tasks (suspends roots, resumes children, resumes roots).
```yaml
- "{{ dbt_dataengineers_materializations.enable_tasks() }}"
```

**enable_alerts** - Resumes alerts.
```yaml
- "{{ dbt_dataengineers_materializations.enable_alerts() }}"
```

**enable_monitorial_monitors** - Resumes monitorial objects.
```yaml
- "{{ dbt_dataengineers_materializations.enable_monitorial_monitors() }}"
```

----

## Monitorial Alerts

```sql
{{
    config(
        materialized='monitorial',
        meta={
            'schedule': '60 minute',
            'display_message': 'alert description',
            'enabled_targets': ['prod']
        }
    )
}}
```

| property | description | required | default |
|---|---|---|---|
| `is_serverless` | serverless (task) or dedicated (alert) | no * | `false` |
| `warehouse_name_or_size` | warehouse size or name | no * | `pc_monitorial_wh` |
| `object_type` | `alert` or `task` | no * | `alert` |
| `schedule` | CRON or minute schedule | yes | `60 minute` |
| `severity` | `Critical`, `Error`, `Warning`, `Info`, `Debug`, `Resolved` | no | `error` |
| `environment` | target environment | no | `target.name` |
| `display_message` | message to send | yes | |
| `prereq` | pre-requisite statement | no | |
| `api_key` | monitorial api key | no * | |
| `message_type` | message type | no | `USER_ALERT` |
| `delivery_type` | `api` or `email` | no | `api` |
| `email_integration` | email integration name | no * | `EXT_EMAIL_MONITORIAL_INTEGRATION` |
| `notification_email` | override email destination | no * | `notifications@monitorial.io` |
| `api_function` | external function for api delivery | no * | `pc_monitorial_db.utils.monitorial_dispatch` |
| `error_integration` | error integration for serverless | no * | `EXT_ERROR_MONITORIAL_INTEGRATION` |
| `enabled_targets` | targets where active | no | `[target.name]` |

Properties marked * can be set as global variables. See [Complete Setup](#complete-setup).

For more information visit [https://www.monitorial.io/](https://www.monitorial.io/)

## Alerts

```sql
{{
    config(
        materialized='alert',
        meta={
            'schedule': '60 minute',
            'action': 'INSERT INTO yourtable VALUES (1)',
            'warehouse_size': 'alert_wh',
            'enabled_targets': ['local-dev', 'test', 'prod']
        }
    )
}}
```

| property | description | required | default |
|---|---|---|---|
| `is_serverless` | use serverless compute | no | `false` |
| `warehouse_size` | warehouse name or size | no | `alert_wh` |
| `schedule` | CRON or minute schedule | yes | `60 minute` |
| `action` | action SQL when condition is true | no | none |
| `enabled_targets` | targets where active | no | `[target.name]` |

## Stored Procedures

```sql
{{
    config(
        materialized='stored_procedure',
        meta={
            'preferred_language': 'sql',
            'override_name': 'SAMPLE_STORE_PROC',
            'parameters': 'status varchar',
            'return_type': 'NUMBER(38, 0)'
        }
    )
}}
```

| property | description | required | default |
|---|---|---|---|
| `preferred_language` | language (`sql`) | no | `sql` |
| `override_name` | override procedure name | no | `model['alias']` |
| `parameters` | parameters as string | no | |
| `return_type` | return type | no | `varchar` |
| `execute_as` | `OWNER` or `CALLER` | no | `owner` |
| `include_copy_grants` | include copy grants | no | `true` |

## File Formats

```sql
{{ config(materialized='file_format', meta={'create_or_replace': true}) }}

    type = json
    null_if = ()
    compression = none
```

| property | description | required | default |
|---|---|---|---|
| `create_or_replace` | `CREATE OR REPLACE` vs `CREATE IF NOT EXISTS` | no | `true` |

[Snowflake CREATE FILE FORMAT docs](https://docs.snowflake.com/en/sql-reference/sql/create-file-format.html)

## Tasks

```sql
{{
    config(
        materialized='task',
        meta={
            'is_serverless': true,
            'schedule': 'using cron */2 6-20 * * * Pacific/Auckland',
            'stream_name': 'stm_orders',
            'enabled_targets': ['prod']
        }
    )
}}
```

| property | description | required | default |
|---|---|---|---|
| `is_serverless` | serverless or dedicated warehouse | no | `true` |
| `warehouse_name_or_size` | warehouse size (serverless) or name | no | `xsmall` |
| `schedule` | CRON schedule (root tasks) | no * | |
| `task_after` | parent task name (child tasks) | no * | |
| `stream_name` | stream for WHEN condition | no | |
| `error_integration` | error integration | no | |
| `timeout` | time limit in milliseconds | no | |
| `suspend_after_number_of_failures` | failures before auto-suspend | no | |
| `enabled_targets` | targets where active | no | `[target.name]` |

* One of `schedule` or `task_after` is required.

**Root task:**
```sql
{{ config(materialized='task', meta={'schedule': 'using cron 0 6 * * * Pacific/Auckland', 'enabled_targets': ['prod']}) }}
```

**Child task:**
```sql
{{ config(materialized='task', meta={'task_after': 'parent_task_name', 'enabled_targets': ['prod']}) }}
```

## Streams

```sql
{{ config(materialized='stream', meta={'source_schema': 'raw', 'source_model': 'customers'}) }}
```

| property | description | required | default |
|---|---|---|---|
| `source_model` | source table or view name | yes | |
| `source_schema` | source schema | no | `schema` |
| `source_database` | source database | no | `database` |
| `source_database_prefix` | variable prefix for dynamic database resolution | no | none |
| `source_type` | `internal` or `external` | no | `internal` |

**External stream:**
```sql
{{ config(materialized='stream', meta={'source_model': 'events', 'source_type': 'external'}) }}
```

## Tables (Auto-Created Source Tables)

```yaml
sources:
  - name: my_source
    tables:
      - name: raw_customers
        columns:
          - name: id
            data_type: number
          - name: name
            data_type: varchar
        external:
          auto_create_table: true
          auto_maintained: true
```

| property | description | required | default |
|---|---|---|---|
| `auto_create_table` | create the table via dbt | yes | `false` |
| `auto_maintained` | maintain schema changes | no | `false` |

### External Tables with Snowpipe

```yaml
external:
  auto_create_table: true
  auto_maintained: true
  location: "@my_stage/events/"
  snowpipe:
    auto_ingest: true
    aws_sns_topic: "arn:aws:sns:us-east-1:123456789:my-topic"
  retain_previous_version_flg: true
  migrate_data_over_flg: true
```

| property | description | default |
|---|---|---|
| `location` | Stage path (e.g., `@my_stage/path/`) | none |
| `snowpipe.auto_ingest` | Enable auto-ingest | `false` |
| `snowpipe.aws_sns_topic` | AWS SNS topic ARN | none |
| `retain_previous_version_flg` | Backup before schema changes | `false` |
| `migrate_data_over_flg` | Migrate data during schema changes | `false` |

Force full refresh: `dbt run --vars '{"ext_full_refresh": true}'`

## Immutable Tables

```sql
{{ config(materialized='immutable_table') }}

SELECT id, name FROM {{ source('raw', 'reference_data') }}
```

| property | description | required | default |
|---|---|---|---|
| `transient` | transient table (ignored if hybrid) | no | `false` |
| `if_not_exists` | only create if not exists | no | `true` |
| `create_or_replace` | CREATE OR REPLACE | no | `false` |
| `data_retention_in_days` | Time Travel retention (ignored if hybrid) | no | none |
| `max_data_extension_in_days` | max retention extension (ignored if hybrid) | no | none |
| `change_tracking` | enable change tracking (ignored if hybrid) | no | `false` |
| `is_hybrid` | create as hybrid table | no | `false` |

**Example: Transient table with time travel**
```sql
{{ config(materialized='immutable_table', meta={'transient': true, 'data_retention_in_days': 7}) }}

SELECT * FROM {{ source('raw', 'audit_log') }}
```

### Hybrid Tables

```sql
{{ config(materialized='immutable_table', meta={'is_hybrid': true, 'primary_keys': ['col_1']}) }}
```

Set `is_unique: true` in column meta for unique constraints. Primary keys default to `auto_increment: true`.

## Stages

```sql
{{ config(materialized='stage', meta={'create_or_replace': true}) }}

{% if target.name == 'prod' %}
  url='azure://xxxxxxprod.blob.core.windows.net/external-tables'
{% else %}
  url='azure://xxxxxxdev.blob.core.windows.net/external-tables'
{% endif %}
  storage_integration = DATAOPS_TEMPLATE_EXTERNAL
```

| property | description | default |
|---|---|---|
| `create_or_replace` | create or replace the stage | `false` |

[Snowflake CREATE STAGE docs](https://docs.snowflake.com/en/sql-reference/sql/create-stage.html)

## Secrets

```sql
{{ config(materialized='secret', meta={'type': 'GENERIC_STRING', 'secret_string_variable': 'MY_VAR'}) }}
```

| property | description | applicable for | default |
|---|---|---|---|
| `type` | `GENERIC_STRING`, `PASSWORD`, `OAUTH2_CLIENT_CREDENTIALS`, `OAUTH2_AUTHORIZATION_CODE` | | `GENERIC_STRING` |
| `secret_string_variable` | env var name | `GENERIC_STRING` | |
| `username` | username | `PASSWORD` | |
| `password_variable` | env var for password | `PASSWORD` | |
| `security_integration` | security integration | `OAUTH2_*` | |
| `oauth_scopes` | OAuth scopes | `OAUTH2_CLIENT_CREDENTIALS` | |
| `oauth_refresh_token_variable` | env var for refresh token | `OAUTH2_AUTHORIZATION_CODE` | |
| `oauth_refresh_token_expiry_time` | token expiry timestamp | `OAUTH2_AUTHORIZATION_CODE` | |

> Do not hardcode secrets. Use environment variables.

## Network Rules

```sql
{{ config(materialized='network_rule', meta={'rule_type': 'HOST_PORT', 'mode': 'EGRESS', 'value_list': ['example.com:443']}) }}
```

| property | description | default |
|---|---|---|
| `rule_type` | `IPV4`, `AWSVPCEID`, `AZURELINKID`, `HOST_PORT` | `HOST_PORT` |
| `mode` | `INGRESS`, `INTERNAL_STAGE`, `EGRESS` | `INGRESS` |
| `value_list` | network identifiers | |

## External Access Integration

```sql
{{
    config(
        materialized='external_access_integration',
        meta={
            'authentication_secrets_refs': ['my_secret'],
            'network_rules_refs': ['my_rule'],
            'role_for_creation': 'dataops_admin',
            'roles_for_use': ['developers']
        }
    )
}}
```

| property | description | default |
|---|---|---|
| `authentication_secrets` / `_refs` | secrets (fully qualified / ref names) | `[]` |
| `network_rules` / `_refs` | network rules (fully qualified / ref names) | `[]` |
| `api_authentication_integrations` / `_refs` | security integrations | `[]` |
| `role_for_creation` | role with CREATE INTEGRATION privilege | `dataops_admin` |
| `roles_for_use` | roles granted USAGE | `['developers']` |

> Requires `CREATE INTEGRATION` privilege. Integration name appends `target.name`.

## General DDL

Execute any DDL not covered by other materializations. Previously named `generic` — renamed to avoid conflicts with dbt's internal generic test type.

```sql
{{ config(materialized='general_ddl') }}

CREATE OR REPLACE API INTEGRATION ext_api_integration
    api_provider = azure_api_management
    azure_tenant_id = 'xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx'
    api_allowed_prefixes = ('https://api.example.com')
    enabled = true;
```

> Integrations require `AccountAdmin`. Use Terraform for integration deployments.

## User Defined Functions

### SQL
```sql
{{ config(materialized='user_defined_function', meta={'return_type': 'float', 'parameters': 'x float, y float'}) }}

AS 'SELECT x + y'
```

| property | description | default |
|---|---|---|
| `preferred_language` | UDF language | `SQL` |
| `is_secure` | secure function | `false` |
| `immutable` | immutable | `false` |
| `memoizable` | memoizable | none |
| `return_type` | return type | (required) |
| `parameters` | params as string | |
| `override_name` | override name | `model['alias']` |

### JavaScript
```sql
{{ config(materialized='user_defined_function', meta={'preferred_language': 'javascript', 'return_type': 'float'}) }}
```
Additional: `null_input_behavior` (default: `CALLED ON NULL INPUT`)

### Java
```sql
{{ config(materialized='user_defined_function', meta={'preferred_language': 'java', 'handler_name': "'pkg.MyClass'", 'target_path': "'@~/myjar.jar'", 'runtime_version': '11', 'return_type': 'varchar'}) }}
```
Additional: `runtime_version`, `packages`, `external_access_integrations`/`_refs`, `secrets`, `handler_name`, `imports`, `target_path`, `null_input_behavior`

### Python
```sql
{{ config(materialized='user_defined_function', meta={'preferred_language': 'python', 'runtime_version': '3.8', 'packages': ['numpy'], 'handler_name': 'udf', 'return_type': 'variant'}) }}
```
Additional: `runtime_version`, `packages`, `handler_name`, `external_access_integrations`, `secrets`, `imports`, `null_input_behavior`

### External Functions
```sql
{{ config(materialized='user_defined_function', meta={'is_external': true, 'api_integration_dev': 'DEV_INT', 'api_integration_prod': 'PROD_INT', 'api_uri_dev': 'https://dev.example.com', 'api_uri_prod': 'https://prod.example.com', 'return_type': 'variant'}) }}
```

| property | description | default |
|---|---|---|
| `is_external` | external function | `false` |
| `api_integration_dev` | API integration for dev | `unknown` |
| `api_integration_prod` | API integration for prod | `unknown` |
| `api_uri_dev` | API URI for dev | `unknown` |
| `api_uri_prod` | API URI for prod | `unknown` |

## Materialized View

```sql
{{ config(materialized='snowflake_materialized_view', cluster_by='field_1, field_2', meta={'secure': false, 'automatic_clustering': false}) }}
```

| property | description | default |
|---|---|---|
| `secure` | secure view | `false` |
| `cluster_by` | clustering expression | none |
| `automatic_clustering` | auto-resume reclustering | `false` |

Supports `persist_docs` (relation only). [Snowflake MV docs](https://docs.snowflake.com/en/user-guide/views-materialized.html)

> MVs require enterprise accounts. If base table is recreated, MV must also be recreated.

## Comments

Enhanced `snowflake__alter_column_comment` and `snowflake__alter_relation_comment` macros support comments on materialized views and dynamic tables. Enabled via the dispatch config in [Complete Setup](#complete-setup).
