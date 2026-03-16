# Snowflake Agent Materialization

This materialization allows you to create and manage Snowflake Cortex Agents using dbt.

## Usage

### YAML Specification as SQL Content (Recommended)

For the cleanest approach, you can put the YAML specification directly as the model's SQL content:

```sql
{{
    config(
        materialized='agent',
        comment='Description of your agent',
        profile='{"display_name": "Agent Name", "avatar": "icon.png", "color": "blue"}'
    )
}}

models:
  orchestration: claude-4-sonnet

orchestration:
  budget:
    seconds: 30
    tokens: 16000

instructions:
  response: "Your response instructions"
  orchestration: "Your orchestration instructions"
  system: "Your system instructions"

tools:
  - tool_spec:
      type: "cortex_analyst_text_to_sql"
      name: "AnalystTool"
      description: "Tool description"

tool_resources:
  AnalystTool:
    semantic_view: "database.schema.view_name"
```


**Run normally:**
```bash
dbt run --models my_agent
```

## Configuration Parameters

| Parameter | Description | Required | Default |
|-----------|-------------|----------|---------|
| `materialized` | Must be set to `'agent'` | Yes | - |
| `comment` | Description of the agent | No | None |
| `profile` | JSON string containing display name, avatar, and color | No | None |


## Profile Object

The profile parameter should be a JSON string with the following structure:
```json
{
  "display_name": "Agent Display Name",
  "avatar": "image-file.png",
  "color": "blue"
}
```

## Specification Object

The specification parameter contains the agent's YAML configuration including:

- **models**: Model configuration (e.g., `orchestration: claude-4-sonnet`)
- **orchestration**: Budget constraints (seconds, tokens)
- **instructions**: Response, orchestration, and system instructions
- **tools**: Array of available tools for the agent
- **tool_resources**: Configuration for each tool

For complete specification format, see the [Snowflake Agent documentation](https://docs.snowflake.com/en/sql-reference/sql/create-agent).

## Examples

- `models/agents_example/my_business_agent.sql` - Example using YAML as SQL content

## Requirements

- Snowflake account with Cortex functionality enabled
- Appropriate privileges to create agents in the target schema
- Access to any semantic views or search services referenced in tool_resources